# SPDX-FileCopyrightText: 2011-2024 Blender Foundation
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Known issues:
# - Doesn't handle multiple materials (don't use material indices).
# - Doesn't handle multiple UV textures on a single mesh (create a mesh for each texture).
# - Can't get the texture array associated with material * not the UV ones.

import logging
logger = logging.getLogger("export_x3d")

import math


import bpy
import mathutils

from bpy_extras.io_utils import create_derived_objects

from .material_node_search import imageTexture_in_material

# h3d defines
H3D_TOP_LEVEL = 'TOP_LEVEL_TI'
H3D_CAMERA_FOLLOW = 'CAMERA_FOLLOW_TRANSFORM'
H3D_VIEW_MATRIX = 'view_matrix'


def clamp_color(col):
    return tuple([max(min(c, 1.0), 0.0) for c in col])


def matrix_direction_neg_z(matrix):
    return (matrix.to_3x3() @ mathutils.Vector((0.0, 0.0, -1.0))).normalized()[:]


def prefix_quoted_str(value, prefix):
    return value[0] + prefix + value[1:]


def suffix_quoted_str(value, suffix):
    return value[:-1] + suffix + value[-1:]


def bool_as_str(value):
    return ('false', 'true')[bool(value)]


def clean_def(txt):
    # see report [#28256]
    if not txt:
        txt = "None"
    # no digit start
    if txt[0] in "1234567890+-":
        txt = "_" + txt
    return txt.translate({
        # control characters 0x0-0x1f
        # 0x00: "_",
        0x01: "_",
        0x02: "_",
        0x03: "_",
        0x04: "_",
        0x05: "_",
        0x06: "_",
        0x07: "_",
        0x08: "_",
        0x09: "_",
        0x0a: "_",
        0x0b: "_",
        0x0c: "_",
        0x0d: "_",
        0x0e: "_",
        0x0f: "_",
        0x10: "_",
        0x11: "_",
        0x12: "_",
        0x13: "_",
        0x14: "_",
        0x15: "_",
        0x16: "_",
        0x17: "_",
        0x18: "_",
        0x19: "_",
        0x1a: "_",
        0x1b: "_",
        0x1c: "_",
        0x1d: "_",
        0x1e: "_",
        0x1f: "_",

        0x7f: "_",  # 127

        0x20: "_",  # space
        0x22: "_",  # "
        0x27: "_",  # '
        0x23: "_",  # #
        0x2c: "_",  # ,
        0x2e: "_",  # .
        0x5b: "_",  # [
        0x5d: "_",  # ]
        0x5c: "_",  # \
        0x7b: "_",  # {
        0x7d: "_",  # }
    })


def build_hierarchy(objects):
    """ returns parent child relationships, skipping
    """
    objects_set = set(objects)
    par_lookup = {}

    def test_parent(parent):
        while (parent is not None) and (parent not in objects_set):
            parent = parent.parent
        return parent

    for obj in objects:
        par_lookup.setdefault(test_parent(obj.parent), []).append((obj, []))

    for parent, children in par_lookup.items():
        for obj, subchildren in children:
            subchildren[:] = par_lookup.get(obj, [])

    return par_lookup.get(None, [])


# -----------------------------------------------------------------------------
# H3D Functions
# -----------------------------------------------------------------------------
def h3d_shader_glsl_frag_patch(filepath, scene, global_vars, frag_uniform_var_map):
    h3d_file = open(filepath, 'r', encoding='utf-8')
    lines = []

    last_transform = None

    for l in h3d_file:
        if l.startswith("void main(void)"):
            lines.append("\n")
            lines.append("// h3d custom vars begin\n")
            for v in global_vars:
                lines.append("%s\n" % v)
            lines.append("// h3d custom vars end\n")
            lines.append("\n")
        elif l.lstrip().startswith("light_visibility_other("):
            w = l.split(', ')
            last_transform = w[1] + "_transform"  # XXX - HACK!!!
            w[1] = '(view_matrix * %s_transform * vec4(%s.x, %s.y, %s.z, 1.0)).xyz' % (w[1], w[1], w[1], w[1])
            l = ", ".join(w)
        elif l.lstrip().startswith("light_visibility_sun_hemi("):
            w = l.split(', ')
            w[0] = w[0][len("light_visibility_sun_hemi(") + 1:]

            if not h3d_is_object_view(scene, frag_uniform_var_map[w[0]]):
                w[0] = '(mat3(normalize(view_matrix[0].xyz), normalize(view_matrix[1].xyz), normalize(view_matrix[2].xyz)) * -%s)' % w[0]
            else:
                w[0] = ('(mat3(normalize((view_matrix*%s)[0].xyz), normalize((view_matrix*%s)[1].xyz), normalize((view_matrix*%s)[2].xyz)) * -%s)' %
                        (last_transform, last_transform, last_transform, w[0]))

            l = "\tlight_visibility_sun_hemi(" + ", ".join(w)
        elif l.lstrip().startswith("light_visibility_spot_circle("):
            w = l.split(', ')
            w[0] = w[0][len("light_visibility_spot_circle(") + 1:]

            if not h3d_is_object_view(scene, frag_uniform_var_map[w[0]]):
                w[0] = '(mat3(normalize(view_matrix[0].xyz), normalize(view_matrix[1].xyz), normalize(view_matrix[2].xyz)) * -%s)' % w[0]
            else:
                w[0] = ('(mat3(normalize((view_matrix*%s)[0].xyz), normalize((view_matrix*%s)[1].xyz), normalize((view_matrix*%s)[2].xyz)) * %s)' %
                        (last_transform, last_transform, last_transform, w[0]))

            l = "\tlight_visibility_spot_circle(" + ", ".join(w)

        lines.append(l)

    h3d_file.close()

    h3d_file = open(filepath, 'w', encoding='utf-8')
    h3d_file.writelines(lines)
    h3d_file.close()


def h3d_is_object_view(scene, obj):
    camera = scene.camera
    parent = obj.parent
    while parent:
        if parent == camera:
            return True
        parent = parent.parent
    return False




# -----------------------------------------------------------------------------
# Functions for writing output file
# -----------------------------------------------------------------------------

def export(file,
           global_matrix,
           depsgraph,
           scene,
           view_layer,
           use_mesh_modifiers=False,
           use_selection=True,
           use_active_collection=False,
           use_visible=False,
           use_triangulate=False,
           use_normals=False,
           use_hierarchy=True,
           use_h3d=False,
           path_mode='COPY',
           name_decorations=True,
           ):

    if path_mode not in ("COPY", "RELATIVE", "STRIP"):
        logger.error("Path Mode %s is invalid, raising ValueError" % path_mode)
        raise ValueError("Invalid Path Mode. Valid values are RELATIVE, STRIP, COPY")
    else:
        logger.debug("export with path_mode: %r" % path_mode)
    # -------------------------------------------------------------------------
    # Global Setup
    # -------------------------------------------------------------------------
    import bpy_extras
    from bpy_extras.io_utils import unique_name
    from xml.sax.saxutils import quoteattr, escape

    if name_decorations:
        # If names are decorated, the uuid map can be split up
        # by type for efficiency of collision testing
        # since objects of different types will always have
        # different decorated names.
        uuid_cache_object = {}    # object
        uuid_cache_light = {}      # 'LA_' + object.name
        uuid_cache_view = {}      # object, different namespace
        uuid_cache_mesh = {}      # mesh
        uuid_cache_material = {}  # material
        uuid_cache_image = {}     # image
        uuid_cache_world = {}     # world
        CA_ = 'CA_'
        OB_ = 'OB_'
        ME_ = 'ME_'
        IM_ = 'IM_'
        WO_ = 'WO_'
        MA_ = 'MA_'
        LA_ = 'LA_'
        group_ = 'group_'
    else:
        # If names are not decorated, it may be possible for two objects to
        # have the same name, so there has to be a unified dictionary to
        # prevent uuid collisions.
        uuid_cache = {}
        uuid_cache_object = uuid_cache           # object
        uuid_cache_light = uuid_cache             # 'LA_' + object.name
        uuid_cache_view = uuid_cache             # object, different namespace
        uuid_cache_mesh = uuid_cache             # mesh
        uuid_cache_material = uuid_cache         # material
        uuid_cache_image = uuid_cache            # image
        uuid_cache_world = uuid_cache            # world
        del uuid_cache
        CA_ = ''
        OB_ = ''
        ME_ = ''
        IM_ = ''
        WO_ = ''
        MA_ = ''
        LA_ = ''
        group_ = ''

    _TRANSFORM = '_TRANSFORM'

    # store files to copy
    copy_set = set()
    import os, os.path
    if path_mode == 'COPY':
        # create a per-export temporary folder. image data which does not
        # exist on disk yet will be saved here from which it can be copied by
        # the bpy_extras.io_utils.path_reference_copy utility
        blender_tempfolder = bpy.app.tempdir
        import uuid
        temporary_image_directory = os.path.join(blender_tempfolder,uuid.uuid4().hex)
        os.mkdir(temporary_image_directory)
        logger.info("temporary_image_directory: %s" % temporary_image_directory )
    else:
        temporary_image_directory = None


    # store names of newly created meshes, so we dont overlap
    mesh_name_set = set()

    fw = file.write
    base_src = os.path.dirname(bpy.data.filepath)
    base_dst = os.path.dirname(file.name)
    filename_strip = os.path.splitext(os.path.basename(file.name))[0]
    gpu_shader_cache = {}

    if use_h3d:
        import gpu
        gpu_shader_dummy_mat = bpy.data.materials.new('X3D_DYMMY_MAT')
        gpu_shader_cache[None] = gpu.export_shader(scene, gpu_shader_dummy_mat)
        h3d_material_route = []

    # -------------------------------------------------------------------------
    # File Writing Functions
    # -------------------------------------------------------------------------

    def writeHeader(ident):
        filepath_quoted = quoteattr(os.path.basename(file.name))
        blender_ver_quoted = quoteattr('Blender %s' % bpy.app.version_string)

        fw('%s<?xml version="1.0" encoding="UTF-8"?>\n' % ident)
        if use_h3d:
            fw('%s<X3D profile="H3DAPI" version="1.4">\n' % ident)
        else:
            fw('%s<!DOCTYPE X3D PUBLIC "ISO//Web3D//DTD X3D 3.0//EN" "http://www.web3d.org/specifications/x3d-3.0.dtd">\n' % ident)
            fw('%s<X3D version="3.0" profile="Immersive" xmlns:xsd="http://www.w3.org/2001/XMLSchema-instance" xsd:noNamespaceSchemaLocation="http://www.web3d.org/specifications/x3d-3.0.xsd">\n' % ident)

        ident += '\t'
        fw('%s<head>\n' % ident)
        ident += '\t'
        fw('%s<meta name="filename" content=%s />\n' % (ident, filepath_quoted))
        fw('%s<meta name="generator" content=%s />\n' % (ident, blender_ver_quoted))
        # this info was never updated, so blender version should be enough
        # fw('%s<meta name="translator" content="X3D exporter v1.55 (2006/01/17)" />\n' % ident)
        ident = ident[:-1]
        fw('%s</head>\n' % ident)
        fw('%s<Scene>\n' % ident)
        ident += '\t'

        if use_h3d:
            # outputs the view matrix in glModelViewMatrix field
            fw('%s<TransformInfo DEF="%s" outputGLMatrices="true" />\n' % (ident, H3D_TOP_LEVEL))

        return ident

    def writeFooter(ident):

        if use_h3d:
            # global
            for route in h3d_material_route:
                fw('%s%s\n' % (ident, route))

        ident = ident[:-1]
        fw('%s</Scene>\n' % ident)
        ident = ident[:-1]
        fw('%s</X3D>' % ident)
        return ident

    def writeViewpoint(ident, obj, matrix, scene):
        view_id = quoteattr(unique_name(obj, CA_ + obj.name, uuid_cache_view, clean_func=clean_def, sep="_"))

        loc, rot, scale = matrix.decompose()
        rot = rot.to_axis_angle()
        rot = (*rot[0].normalized(), rot[1])

        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<Viewpoint ' % ident)))
        fw('DEF=%s\n' % view_id)
        fw(ident_step + 'centerOfRotation="0 0 0"\n')
        fw(ident_step + 'position="%3.2f %3.2f %3.2f"\n' % loc[:])
        fw(ident_step + 'orientation="%3.2f %3.2f %3.2f %3.2f"\n' % rot)
        fw(ident_step + 'fieldOfView="%.3f"\n' % obj.data.angle)
        fw(ident_step + '/>\n')

    def writeFog(ident, world):
        if world:
            mtype = world.mist_settings.falloff
            mparam = world.mist_settings
        else:
            return

        if mparam.use_mist:
            ident_step = ident + (' ' * (-len(ident) +
                                         fw('%s<Fog ' % ident)))
            fw('fogType="%s"\n' % ('LINEAR' if (mtype == 'LINEAR') else 'EXPONENTIAL'))
            fw(ident_step + 'color="%.3f %.3f %.3f"\n' % clamp_color(world.horizon_color))
            fw(ident_step + 'visibilityRange="%.3f"\n' % mparam.depth)
            fw(ident_step + '/>\n')
        else:
            return

    def writeNavigationInfo(ident, scene, has_light):
        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<NavigationInfo ' % ident)))
        fw('headlight="%s"\n' % bool_as_str(not has_light))
        fw(ident_step + 'visibilityLimit="0.0"\n')
        fw(ident_step + 'type=\'"EXAMINE", "ANY"\'\n')
        fw(ident_step + 'avatarSize="0.25, 1.75, 0.75"\n')
        fw(ident_step + '/>\n')

    def writeTransform_begin(ident, matrix, def_id):
        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<Transform ' % ident)))
        if def_id is not None:
            fw('DEF=%s\n' % def_id)
        else:
            fw('\n')

        loc, rot, sca = matrix.decompose()
        rot = rot.to_axis_angle()
        rot = (*rot[0], rot[1])

        fw(ident_step + 'translation="%.6f %.6f %.6f"\n' % loc[:])
        # fw(ident_step + 'center="%.6f %.6f %.6f"\n' % (0, 0, 0))
        fw(ident_step + 'scale="%.6f %.6f %.6f"\n' % sca[:])
        fw(ident_step + 'rotation="%.6f %.6f %.6f %.6f"\n' % rot)
        fw(ident_step + '>\n')
        ident += '\t'
        return ident

    def writeTransform_end(ident):
        ident = ident[:-1]
        fw('%s</Transform>\n' % ident)
        return ident

    def writeSpotLight(ident, obj, matrix, light, world):
        # note, light_id is not re-used
        light_id = quoteattr(unique_name(obj, LA_ + obj.name, uuid_cache_light, clean_func=clean_def, sep="_"))

        if world and 0:
            ambi = world.ambient_color
            amb_intensity = ((ambi[0] + ambi[1] + ambi[2]) / 3.0) / 2.5
            del ambi
        else:
            amb_intensity = 0.0

        # compute cutoff and beamwidth
        intensity = min(light.energy / 1.75, 1.0)
        beamWidth = light.spot_size * 0.37
        # beamWidth=((light.spotSize*math.pi)/180.0)*.37
        cutOffAngle = beamWidth * 1.3

        orientation = matrix_direction_neg_z(matrix)

        location = matrix.to_translation()[:]

        radius = light.cutoff_distance * math.cos(beamWidth)
        # radius = light.dist*math.cos(beamWidth)
        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<SpotLight ' % ident)))
        fw('DEF=%s\n' % light_id)
        fw(ident_step + 'radius="%.4f"\n' % radius)
        fw(ident_step + 'ambientIntensity="%.4f"\n' % amb_intensity)
        fw(ident_step + 'intensity="%.4f"\n' % intensity)
        fw(ident_step + 'color="%.4f %.4f %.4f"\n' % clamp_color(light.color))
        fw(ident_step + 'beamWidth="%.4f"\n' % beamWidth)
        fw(ident_step + 'cutOffAngle="%.4f"\n' % cutOffAngle)
        fw(ident_step + 'direction="%.4f %.4f %.4f"\n' % orientation)
        fw(ident_step + 'location="%.4f %.4f %.4f"\n' % location)
        fw(ident_step + '/>\n')

    def writeDirectionalLight(ident, obj, matrix, light, world):
        # note, light_id is not re-used
        light_id = quoteattr(unique_name(obj, LA_ + obj.name, uuid_cache_light, clean_func=clean_def, sep="_"))

        if world and 0:
            ambi = world.ambient_color
            # ambi = world.amb
            amb_intensity = ((float(ambi[0] + ambi[1] + ambi[2])) / 3.0) / 2.5
        else:
            ambi = 0
            amb_intensity = 0.0

        intensity = min(light.energy / 1.75, 1.0)

        orientation = matrix_direction_neg_z(matrix)

        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<DirectionalLight ' % ident)))
        fw('DEF=%s\n' % light_id)
        fw(ident_step + 'ambientIntensity="%.4f"\n' % amb_intensity)
        fw(ident_step + 'color="%.4f %.4f %.4f"\n' % clamp_color(light.color))
        fw(ident_step + 'intensity="%.4f"\n' % intensity)
        fw(ident_step + 'direction="%.4f %.4f %.4f"\n' % orientation)
        fw(ident_step + '/>\n')

    def writePointLight(ident, obj, matrix, light, world):
        # note, light_id is not re-used
        light_id = quoteattr(unique_name(obj, LA_ + obj.name, uuid_cache_light, clean_func=clean_def, sep="_"))

        if world and 0:
            ambi = world.ambient_color
            # ambi = world.amb
            amb_intensity = ((float(ambi[0] + ambi[1] + ambi[2])) / 3.0) / 2.5
        else:
            ambi = 0.0
            amb_intensity = 0.0

        intensity = min(light.energy / 1.75, 1.0)
        location = matrix.to_translation()[:]

        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<PointLight ' % ident)))
        fw('DEF=%s\n' % light_id)
        fw(ident_step + 'ambientIntensity="%.4f"\n' % amb_intensity)
        fw(ident_step + 'color="%.4f %.4f %.4f"\n' % clamp_color(light.color))

        fw(ident_step + 'intensity="%.4f"\n' % intensity)
        fw(ident_step + 'radius="%.4f" \n' % light.cutoff_distance)
        fw(ident_step + 'location="%.4f %.4f %.4f"\n' % location)
        fw(ident_step + '/>\n')

    def writeIndexedFaceSet(ident, obj, mesh, mesh_name, matrix, world):
        obj_id = quoteattr(unique_name(obj, OB_ + obj.name, uuid_cache_object, clean_func=clean_def, sep="_"))
        mesh_id = quoteattr(unique_name(mesh, ME_ + mesh_name, uuid_cache_mesh, clean_func=clean_def, sep="_"))
        mesh_id_group = prefix_quoted_str(mesh_id, group_)
        mesh_id_coords = prefix_quoted_str(mesh_id, 'coords_')
        mesh_id_normals = prefix_quoted_str(mesh_id, 'normals_')

        # Be sure tessellated loop triangles are available!
        if use_triangulate:
            if not mesh.loop_triangles and mesh.polygons:
                mesh.calc_loop_triangles()

        use_collnode = bool([mod for mod in obj.modifiers
                             if mod.type == 'COLLISION'
                             if mod.show_viewport])

        if use_collnode:
            fw('%s<Collision enabled="true">\n' % ident)
            ident += '\t'

        # use _ifs_TRANSFORM suffix so we dont collide with transform node when
        # hierarchys are used.
        ident = writeTransform_begin(ident, matrix, suffix_quoted_str(obj_id, "_ifs" + _TRANSFORM))

        if mesh.tag:
            fw('%s<Group USE=%s />\n' % (ident, mesh_id_group))
        else:
            mesh.tag = True

            fw('%s<Group DEF=%s>\n' % (ident, mesh_id_group))
            ident += '\t'

            is_uv = bool(mesh.uv_layers.active)
            # is_col, defined for each material

            is_coords_written = False

            # fast access!
            mesh_vertices = mesh.vertices[:]
            mesh_loops = mesh.loops[:]
            mesh_polygons = mesh.polygons[:]
            mesh_polygons_materials = [p.material_index for p in mesh_polygons]
            mesh_polygons_vertices = [p.vertices[:] for p in mesh_polygons]

            # group faces
            polygons_groups = {}
            for material_index in range(len(mesh.materials)):
                polygons_groups[material_index] = []


            for i, material_index in enumerate(mesh_polygons_materials):
                polygons_groups[material_index].append(i)

            # Py dict are sorted now, so we can use directly polygons_groups.items()
            # and still get consistent reproducible outputs.

            is_col = mesh.vertex_colors.active
            mesh_loops_col = mesh.vertex_colors.active.data if is_col else None

            # Check if vertex colors can be exported in per-vertex mode.
            # Do we have just one color per vertex in every face that uses the vertex?
            if is_col:
                def calc_vertex_color():
                    vert_color = [None] * len(mesh.vertices)

                    for i, p in enumerate(mesh_polygons):
                        for lidx in p.loop_indices:
                            l = mesh_loops[lidx]
                            if vert_color[l.vertex_index] is None:
                                vert_color[l.vertex_index] = mesh_loops_col[lidx].color[:]
                            elif vert_color[l.vertex_index] != mesh_loops_col[lidx].color[:]:
                                return False, ()

                    return True, vert_color

                is_col_per_vertex, vert_color = calc_vertex_color()
                del calc_vertex_color

            # If using looptris, we need a mapping poly_index -> loop_tris_indices...
            if use_triangulate:
                polygons_to_loop_triangles_indices = [[] for i in range(len(mesh_polygons))]
                for ltri in mesh.loop_triangles:
                    polygons_to_loop_triangles_indices[ltri.polygon_index].append(ltri)

            for material_index, polygons_group in polygons_groups.items():
                if polygons_group:
                    material = mesh.materials[material_index]

                    fw('%s<Shape>\n' % ident)
                    ident += '\t'

                    is_smooth = False

                    # kludge but as good as it gets!
                    for i in polygons_group:
                        if mesh_polygons[i].use_smooth:
                            is_smooth = True
                            break

                    # UV's and VCols split verts off which effects smoothing
                    # force writing normals in this case.
                    # Also, creaseAngle is not supported for IndexedTriangleSet,
                    # so write normals when is_smooth (otherwise
                    # IndexedTriangleSet can have only all smooth/all flat shading).
                    is_force_normals = use_triangulate and (is_smooth or is_uv or is_col)

                    if use_h3d:
                        gpu_shader = gpu_shader_cache.get(material)  # material can be 'None', uses dummy cache
                        if gpu_shader is None:
                            gpu_shader = gpu_shader_cache[material] = gpu.export_shader(scene, material)

                            if 1:  # XXX DEBUG
                                gpu_shader_tmp = gpu.export_shader(scene, material)
                                import pprint
                                print('\nWRITING MATERIAL:', material.name)
                                del gpu_shader_tmp['fragment']
                                del gpu_shader_tmp['vertex']
                                pprint.pprint(gpu_shader_tmp, width=120)
                                # pprint.pprint(val['vertex'])
                                del gpu_shader_tmp

                    fw('%s<Appearance>\n' % ident)
                    ident += '\t'

                    imageTextureNode = imageTexture_in_material(material)
                    if imageTextureNode:
                        writeImageTexture(ident, imageTextureNode)

                    if use_h3d:
                        mat_tmp = material if material else gpu_shader_dummy_mat
                        writeMaterialH3D(ident, mat_tmp, world,
                                         obj, gpu_shader)
                        del mat_tmp
                    else:
                        if material:
                            writeMaterial(ident, material, world)

                    ident = ident[:-1]
                    fw('%s</Appearance>\n' % ident)

                    mesh_loops_uv = mesh.uv_layers.active.data if is_uv else None

                    # -- IndexedFaceSet or IndexedLineSet
                    if use_triangulate:
                        ident_step = ident + (' ' * (-len(ident) +
                                                     fw('%s<IndexedTriangleSet ' % ident)))

                        # --- Write IndexedTriangleSet Attributes (same as IndexedFaceSet)
                        fw('solid="%s"\n' % bool_as_str(material and material.use_backface_culling))

                        if use_normals or is_force_normals:
                            fw(ident_step + 'normalPerVertex="true"\n')
                        else:
                            # Tell X3D browser to generate flat (per-face) normals
                            fw(ident_step + 'normalPerVertex="false"\n')

                        slot_uv = None
                        slot_col = None

                        def _tuple_from_rounded_iter(it):
                            return tuple(round(v, 5) for v in it)

                        if is_uv and is_col:
                            slot_uv = 0
                            slot_col = 1

                            def vertex_key(lidx):
                                return (
                                    _tuple_from_rounded_iter(mesh_loops_uv[lidx].uv),
                                    _tuple_from_rounded_iter(mesh_loops_col[lidx].color),
                                )
                        elif is_uv:
                            slot_uv = 0

                            def vertex_key(lidx):
                                return (
                                    _tuple_from_rounded_iter(mesh_loops_uv[lidx].uv),
                                )
                        elif is_col:
                            slot_col = 0

                            def vertex_key(lidx):
                                return (
                                    _tuple_from_rounded_iter(mesh_loops_col[lidx].color),
                                )
                        else:
                            # ack, not especially efficient in this case
                            def vertex_key(lidx):
                                return None

                        # build a mesh mapping dict
                        vertex_hash = [{} for i in range(len(mesh.vertices))]
                        face_tri_list = [[None, None, None] for i in range(len(mesh.loop_triangles))]
                        vert_tri_list = []
                        totvert = 0
                        totface = 0
                        temp_tri = [None] * 3
                        for pidx in polygons_group:
                            for ltri in polygons_to_loop_triangles_indices[pidx]:
                                for tri_vidx, (lidx, vidx) in enumerate(zip(ltri.loops, ltri.vertices)):
                                    key = vertex_key(lidx)
                                    vh = vertex_hash[vidx]
                                    x3d_v = vh.get(key)
                                    if x3d_v is None:
                                        x3d_v = key, vidx, totvert
                                        vh[key] = x3d_v
                                        # key / original_vertex / new_vertex
                                        vert_tri_list.append(x3d_v)
                                        totvert += 1
                                    temp_tri[tri_vidx] = x3d_v

                                face_tri_list[totface][:] = temp_tri[:]
                                totface += 1

                        del vertex_key
                        del _tuple_from_rounded_iter
                        assert (len(face_tri_list) == len(mesh.loop_triangles))

                        fw(ident_step + 'index="')
                        for x3d_f in face_tri_list:
                            fw('%i %i %i ' % (x3d_f[0][2], x3d_f[1][2], x3d_f[2][2]))
                        fw('"\n')

                        # close IndexedTriangleSet
                        fw(ident_step + '>\n')
                        ident += '\t'

                        fw('%s<Coordinate ' % ident)
                        fw('point="')
                        for x3d_v in vert_tri_list:
                            fw('%.6f %.6f %.6f ' % mesh_vertices[x3d_v[1]].co[:])
                        fw('" />\n')

                        if use_normals or is_force_normals:
                            fw('%s<Normal ' % ident)
                            fw('vector="')
                            for x3d_v in vert_tri_list:
                                fw('%.6f %.6f %.6f ' % mesh_vertices[x3d_v[1]].normal[:])
                            fw('" />\n')

                        if is_uv:
                            fw('%s<TextureCoordinate point="' % ident)
                            for x3d_v in vert_tri_list:
                                fw('%.4f %.4f ' % x3d_v[0][slot_uv])
                            fw('" />\n')

                        if is_col:
                            fw('%s<ColorRGBA color="' % ident)
                            for x3d_v in vert_tri_list:
                                fw('%.3f %.3f %.3f %.3f ' % x3d_v[0][slot_col])
                            fw('" />\n')

                        if use_h3d:
                            # write attributes
                            for gpu_attr in gpu_shader['attributes']:

                                # UVs
                                if gpu_attr['type'] == gpu.CD_MTFACE:
                                    if gpu_attr['datatype'] == gpu.GPU_DATA_2F:
                                        fw('%s<FloatVertexAttribute ' % ident)
                                        fw('name="%s" ' % gpu_attr['varname'])
                                        fw('numComponents="2" ')
                                        fw('value="')
                                        for x3d_v in vert_tri_list:
                                            fw('%.4f %.4f ' % x3d_v[0][slot_uv])
                                        fw('" />\n')
                                    else:
                                        assert (0)

                                elif gpu_attr['type'] == gpu.CD_MCOL:
                                    if gpu_attr['datatype'] == gpu.GPU_DATA_4UB:
                                        pass  # XXX, H3D can't do
                                    else:
                                        assert (0)

                        ident = ident[:-1]

                        fw('%s</IndexedTriangleSet>\n' % ident)

                    else:
                        ident_step = ident + (' ' * (-len(ident) +
                                                     fw('%s<IndexedFaceSet ' % ident)))

                        # --- Write IndexedFaceSet Attributes (same as IndexedTriangleSet)
                        fw('solid="%s"\n' % bool_as_str(material and material.use_backface_culling))

                        if use_normals:
                            # currently not optional, could be made so:
                            fw(ident_step + 'normalPerVertex="true"\n')

                        # IndexedTriangleSet assumes true
                        if is_col and not is_col_per_vertex:
                            fw(ident_step + 'colorPerVertex="false"\n')

                        # for IndexedTriangleSet we use a uv per vertex so this isn't needed.
                        if is_uv:
                            fw(ident_step + 'texCoordIndex="')

                            j = 0
                            for i in polygons_group:
                                num_poly_verts = len(mesh_polygons_vertices[i])
                                fw('%s -1 ' % ' '.join((str(i) for i in range(j, j + num_poly_verts))))
                                j += num_poly_verts
                            fw('"\n')
                            # --- end texCoordIndex

                        if True:
                            fw(ident_step + 'coordIndex="')
                            for i in polygons_group:
                                poly_verts = mesh_polygons_vertices[i]
                                fw('%s -1 ' % ' '.join((str(i) for i in poly_verts)))

                            fw('"\n')
                            # --- end coordIndex

                        # close IndexedFaceSet
                        fw(ident_step + '>\n')
                        ident += '\t'

                        # --- Write IndexedFaceSet Elements
                        if True:
                            if is_coords_written:
                                fw('%s<Coordinate USE=%s />\n' % (ident, mesh_id_coords))
                                if use_normals:
                                    fw('%s<Normal USE=%s />\n' % (ident, mesh_id_normals))
                            else:
                                ident_step = ident + (' ' * (-len(ident) +
                                                             fw('%s<Coordinate ' % ident)))
                                fw('DEF=%s\n' % mesh_id_coords)
                                fw(ident_step + 'point="')
                                for v in mesh.vertices:
                                    fw('%.6f %.6f %.6f ' % v.co[:])
                                fw('"\n')
                                fw(ident_step + '/>\n')

                                is_coords_written = True

                                if use_normals:
                                    ident_step = ident + (' ' * (-len(ident) +
                                                                 fw('%s<Normal ' % ident)))
                                    fw('DEF=%s\n' % mesh_id_normals)
                                    fw(ident_step + 'vector="')
                                    for v in mesh.vertices:
                                        fw('%.6f %.6f %.6f ' % v.normal[:])
                                    fw('"\n')
                                    fw(ident_step + '/>\n')

                        if is_uv:
                            fw('%s<TextureCoordinate point="' % ident)
                            for i in polygons_group:
                                for lidx in mesh_polygons[i].loop_indices:
                                    fw('%.4f %.4f ' % mesh_loops_uv[lidx].uv[:])
                            fw('" />\n')

                        if is_col:
                            # Need better logic here, dynamic determination
                            # which of the X3D coloring models fits better this mesh - per face
                            # or per vertex. Probably with an explicit fallback mode parameter.
                            fw('%s<ColorRGBA color="' % ident)
                            if is_col_per_vertex:
                                for i in range(len(mesh.vertices)):
                                    # may be None,
                                    fw('%.3f %.3f %.3f %.3f ' % (vert_color[i] or (0.0, 0.0, 0.0, 0.0)))
                            else:  # Export as colors per face.
                                # TODO: average them rather than using the first one!
                                for i in polygons_group:
                                    fw('%.3f %.3f %.3f %.3f ' % mesh_loops_col[mesh_polygons[i].loop_start].color[:])
                            fw('" />\n')

                        # --- output vertexColors

                        # --- output closing braces
                        ident = ident[:-1]

                        fw('%s</IndexedFaceSet>\n' % ident)

                    ident = ident[:-1]
                    fw('%s</Shape>\n' % ident)

                    # XXX

            # fw('%s<PythonScript DEF="PS" url="object.py" >\n' % ident)
            # fw('%s    <ShaderProgram USE="MA_Material.005" containerField="references"/>\n' % ident)
            # fw('%s</PythonScript>\n' % ident)

            ident = ident[:-1]
            fw('%s</Group>\n' % ident)

        ident = writeTransform_end(ident)

        if use_collnode:
            ident = ident[:-1]
            fw('%s</Collision>\n' % ident)

    def writeMaterial(ident, material, world):
        material_id = quoteattr(unique_name(material, MA_ + material.name, uuid_cache_material, clean_func=clean_def, sep="_"))

        # look up material name, use it if available
        if material.tag:
            fw('%s<Material USE=%s />\n' % (ident, material_id))
        else:
            material.tag = True

            emit = 0.0  # material.emit
            ambient = 0.0  # material.ambient / 3.0
            diffuseColor = material.diffuse_color[:3]
            if world and 0:
                ambiColor = ((material.ambient * 2.0) * world.ambient_color)[:]
            else:
                ambiColor = 0.0, 0.0, 0.0

            emitColor = tuple(((c * emit) + ambiColor[i]) / 2.0 for i, c in enumerate(diffuseColor))
            shininess = material.specular_intensity
            specColor = tuple((c + 0.001) / (1.25 / (material.specular_intensity + 0.001)) for c in material.specular_color)
            transp = 1.0 - material.diffuse_color[3]

            # ~ if material.use_shadeless:
            # ~ ambient = 1.0
            # ~ shininess = 0.0
            # ~ specColor = emitColor = diffuseColor

            ident_step = ident + (' ' * (-len(ident) +
                                         fw('%s<Material ' % ident)))
            fw('DEF=%s\n' % material_id)
            fw(ident_step + 'diffuseColor="%.3f %.3f %.3f"\n' % clamp_color(diffuseColor))
            fw(ident_step + 'specularColor="%.3f %.3f %.3f"\n' % clamp_color(specColor))
            fw(ident_step + 'emissiveColor="%.3f %.3f %.3f"\n' % clamp_color(emitColor))
            fw(ident_step + 'ambientIntensity="%.3f"\n' % ambient)
            fw(ident_step + 'shininess="%.3f"\n' % shininess)
            fw(ident_step + 'transparency="%s"\n' % transp)
            fw(ident_step + '/>\n')

    def writeMaterialH3D(ident, material, world,
                         obj, gpu_shader):
        material_id = quoteattr(unique_name(material, 'MA_' + material.name, uuid_cache_material, clean_func=clean_def, sep="_"))

        fw('%s<Material />\n' % ident)
        if material.tag:
            fw('%s<ComposedShader USE=%s />\n' % (ident, material_id))
        else:
            material.tag = True

            # GPU_material_bind_uniforms
            # GPU_begin_object_materials

            # ~ CD_MCOL 6
            # ~ CD_MTFACE 5
            # ~ CD_ORCO 14
            # ~ CD_TANGENT 18
            # ~ GPU_DATA_16F 7
            # ~ GPU_DATA_1F 2
            # ~ GPU_DATA_1I 1
            # ~ GPU_DATA_2F 3
            # ~ GPU_DATA_3F 4
            # ~ GPU_DATA_4F 5
            # ~ GPU_DATA_4UB 8
            # ~ GPU_DATA_9F 6
            # ~ GPU_DYNAMIC_LIGHT_DYNCO 7
            # ~ GPU_DYNAMIC_LIGHT_DYNCOL 11
            # ~ GPU_DYNAMIC_LIGHT_DYNENERGY 10
            # ~ GPU_DYNAMIC_LIGHT_DYNIMAT 8
            # ~ GPU_DYNAMIC_LIGHT_DYNPERSMAT 9
            # ~ GPU_DYNAMIC_LIGHT_DYNVEC 6
            # ~ GPU_DYNAMIC_OBJECT_COLOR 5
            # ~ GPU_DYNAMIC_OBJECT_IMAT 4
            # ~ GPU_DYNAMIC_OBJECT_MAT 2
            # ~ GPU_DYNAMIC_OBJECT_VIEWIMAT 3
            # ~ GPU_DYNAMIC_OBJECT_VIEWMAT 1
            # ~ GPU_DYNAMIC_SAMPLER_2DBUFFER 12
            # ~ GPU_DYNAMIC_SAMPLER_2DIMAGE 13
            # ~ GPU_DYNAMIC_SAMPLER_2DSHADOW 14

            '''
            inline const char* typeToString( X3DType t ) {
              switch( t ) {
              case     SFFLOAT: return "SFFloat";
              case     MFFLOAT: return "MFFloat";
              case    SFDOUBLE: return "SFDouble";
              case    MFDOUBLE: return "MFDouble";
              case      SFTIME: return "SFTime";
              case      MFTIME: return "MFTime";
              case     SFINT32: return "SFInt32";
              case     MFINT32: return "MFInt32";
              case     SFVEC2F: return "SFVec2f";
              case     MFVEC2F: return "MFVec2f";
              case     SFVEC2D: return "SFVec2d";
              case     MFVEC2D: return "MFVec2d";
              case     SFVEC3F: return "SFVec3f";
              case     MFVEC3F: return "MFVec3f";
              case     SFVEC3D: return "SFVec3d";
              case     MFVEC3D: return "MFVec3d";
              case     SFVEC4F: return "SFVec4f";
              case     MFVEC4F: return "MFVec4f";
              case     SFVEC4D: return "SFVec4d";
              case     MFVEC4D: return "MFVec4d";
              case      SFBOOL: return "SFBool";
              case      MFBOOL: return "MFBool";
              case    SFSTRING: return "SFString";
              case    MFSTRING: return "MFString";
              case      SFNODE: return "SFNode";
              case      MFNODE: return "MFNode";
              case     SFCOLOR: return "SFColor";
              case     MFCOLOR: return "MFColor";
              case SFCOLORRGBA: return "SFColorRGBA";
              case MFCOLORRGBA: return "MFColorRGBA";
              case  SFROTATION: return "SFRotation";
              case  MFROTATION: return "MFRotation";
              case  SFQUATERNION: return "SFQuaternion";
              case  MFQUATERNION: return "MFQuaternion";
              case  SFMATRIX3F: return "SFMatrix3f";
              case  MFMATRIX3F: return "MFMatrix3f";
              case  SFMATRIX4F: return "SFMatrix4f";
              case  MFMATRIX4F: return "MFMatrix4f";
              case  SFMATRIX3D: return "SFMatrix3d";
              case  MFMATRIX3D: return "MFMatrix3d";
              case  SFMATRIX4D: return "SFMatrix4d";
              case  MFMATRIX4D: return "MFMatrix4d";
              case UNKNOWN_X3D_TYPE:
              default:return "UNKNOWN_X3D_TYPE";
            '''
            import gpu

            fw('%s<ComposedShader DEF=%s language="GLSL" >\n' % (ident, material_id))
            ident += '\t'

            shader_url_frag = 'shaders/%s_%s.frag' % (filename_strip, material_id[1:-1])
            shader_url_vert = 'shaders/%s_%s.vert' % (filename_strip, material_id[1:-1])

            # write files
            shader_dir = os.path.join(base_dst, 'shaders')
            if not os.path.isdir(shader_dir):
                os.mkdir(shader_dir)

            # ------------------------------------------------------
            # shader-patch
            field_descr = " <!--- H3D View Matrix Patch -->"
            fw('%s<field name="%s" type="SFMatrix4f" accessType="inputOutput" />%s\n' % (ident, H3D_VIEW_MATRIX, field_descr))
            frag_vars = ["uniform mat4 %s;" % H3D_VIEW_MATRIX]

            # annoying!, we need to track if some of the directional lamp
            # vars are children of the camera or not, since this adjusts how
            # they are patched.
            frag_uniform_var_map = {}

            h3d_material_route.append(
                '<ROUTE fromNode="%s" fromField="glModelViewMatrix" toNode=%s toField="%s" />%s' %
                (H3D_TOP_LEVEL, material_id, H3D_VIEW_MATRIX, field_descr))
            # ------------------------------------------------------

            for uniform in gpu_shader['uniforms']:
                if uniform['type'] == gpu.GPU_DYNAMIC_SAMPLER_2DIMAGE:
                    field_descr = " <!--- Dynamic Sampler 2d Image -->"
                    fw('%s<field name="%s" type="SFNode" accessType="inputOutput">%s\n' % (ident, uniform['varname'], field_descr))
                    writeImageTexture(ident + '\t', uniform['image'])
                    fw('%s</field>\n' % ident)

                elif uniform['type'] == gpu.GPU_DYNAMIC_LIGHT_DYNCO:
                    light_obj = uniform['lamp']
                    frag_uniform_var_map[uniform['varname']] = light_obj

                    if uniform['datatype'] == gpu.GPU_DATA_3F:  # should always be true!
                        light_obj_id = quoteattr(unique_name(light_obj, LA_ + light_obj.name, uuid_cache_light, clean_func=clean_def, sep="_"))
                        light_obj_transform_id = quoteattr(unique_name(light_obj, light_obj.name, uuid_cache_object, clean_func=clean_def, sep="_"))

                        value = '%.6f %.6f %.6f' % (global_matrix * light_obj.matrix_world).to_translation()[:]
                        field_descr = " <!--- Lamp DynCo '%s' -->" % light_obj.name
                        fw('%s<field name="%s" type="SFVec3f" accessType="inputOutput" value="%s" />%s\n' % (ident, uniform['varname'], value, field_descr))

                        # ------------------------------------------------------
                        # shader-patch
                        field_descr = " <!--- Lamp DynCo '%s' (shader patch) -->" % light_obj.name
                        fw('%s<field name="%s_transform" type="SFMatrix4f" accessType="inputOutput" />%s\n' % (ident, uniform['varname'], field_descr))

                        # transform
                        frag_vars.append("uniform mat4 %s_transform;" % uniform['varname'])
                        h3d_material_route.append(
                            '<ROUTE fromNode=%s fromField="accumulatedForward" toNode=%s toField="%s_transform" />%s' %
                            (suffix_quoted_str(light_obj_transform_id, _TRANSFORM), material_id, uniform['varname'], field_descr))

                        h3d_material_route.append(
                            '<ROUTE fromNode=%s fromField="location" toNode=%s toField="%s" /> %s' %
                            (light_obj_id, material_id, uniform['varname'], field_descr))
                        # ------------------------------------------------------

                    else:
                        assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_LIGHT_DYNCOL:
                    # odd  we have both 3, 4 types.
                    light_obj = uniform['lamp']
                    frag_uniform_var_map[uniform['varname']] = light_obj

                    lamp = light_obj.data
                    value = '%.6f %.6f %.6f' % (lamp.color * lamp.energy)[:]
                    field_descr = " <!--- Lamp DynColor '%s' -->" % light_obj.name
                    if uniform['datatype'] == gpu.GPU_DATA_3F:
                        fw('%s<field name="%s" type="SFVec3f" accessType="inputOutput" value="%s" />%s\n' % (ident, uniform['varname'], value, field_descr))
                    elif uniform['datatype'] == gpu.GPU_DATA_4F:
                        fw('%s<field name="%s" type="SFVec4f" accessType="inputOutput" value="%s 1.0" />%s\n' % (ident, uniform['varname'], value, field_descr))
                    else:
                        assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_LIGHT_DYNENERGY:
                    # not used ?
                    assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_LIGHT_DYNVEC:
                    light_obj = uniform['lamp']
                    frag_uniform_var_map[uniform['varname']] = light_obj

                    if uniform['datatype'] == gpu.GPU_DATA_3F:
                        light_obj = uniform['lamp']
                        value = '%.6f %.6f %.6f' % ((global_matrix * light_obj.matrix_world).to_quaternion() * mathutils.Vector((0.0, 0.0, 1.0))).normalized()[:]
                        field_descr = " <!--- Lamp DynDirection '%s' -->" % light_obj.name
                        fw('%s<field name="%s" type="SFVec3f" accessType="inputOutput" value="%s" />%s\n' % (ident, uniform['varname'], value, field_descr))

                        # route so we can have the lamp update the view
                        if h3d_is_object_view(scene, light_obj):
                            light_id = quoteattr(unique_name(light_obj, LA_ + light_obj.name, uuid_cache_light, clean_func=clean_def, sep="_"))
                            h3d_material_route.append(
                                '<ROUTE fromNode=%s fromField="direction" toNode=%s toField="%s" />%s' %
                                (light_id, material_id, uniform['varname'], field_descr))

                    else:
                        assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_OBJECT_VIEWIMAT:
                    frag_uniform_var_map[uniform['varname']] = None
                    if uniform['datatype'] == gpu.GPU_DATA_16F:
                        field_descr = " <!--- Object View Matrix Inverse '%s' -->" % obj.name
                        fw('%s<field name="%s" type="SFMatrix4f" accessType="inputOutput" />%s\n' % (ident, uniform['varname'], field_descr))

                        h3d_material_route.append(
                            '<ROUTE fromNode="%s" fromField="glModelViewMatrixInverse" toNode=%s toField="%s" />%s' %
                            (H3D_TOP_LEVEL, material_id, uniform['varname'], field_descr))
                    else:
                        assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_OBJECT_IMAT:
                    frag_uniform_var_map[uniform['varname']] = None
                    if uniform['datatype'] == gpu.GPU_DATA_16F:
                        value = ' '.join(['%.6f' % f for v in (global_matrix * obj.matrix_world).inverted().transposed() for f in v])
                        field_descr = " <!--- Object Invertex Matrix '%s' -->" % obj.name
                        fw('%s<field name="%s" type="SFMatrix4f" accessType="inputOutput" value="%s" />%s\n' % (ident, uniform['varname'], value, field_descr))
                    else:
                        assert (0)

                elif uniform['type'] == gpu.GPU_DYNAMIC_SAMPLER_2DSHADOW:
                    pass  # XXX, shadow buffers not supported.

                elif uniform['type'] == gpu.GPU_DYNAMIC_SAMPLER_2DBUFFER:
                    frag_uniform_var_map[uniform['varname']] = None

                    if uniform['datatype'] == gpu.GPU_DATA_1I:
                        if 1:
                            tex = uniform['texpixels']
                            value = []
                            for i in range(0, len(tex) - 1, 4):
                                col = tex[i:i + 4]
                                value.append('0x%.2x%.2x%.2x%.2x' % (col[0], col[1], col[2], col[3]))

                            field_descr = " <!--- Material Buffer -->"
                            fw('%s<field name="%s" type="SFNode" accessType="inputOutput">%s\n' % (ident, uniform['varname'], field_descr))

                            ident += '\t'

                            ident_step = ident + (' ' * (-len(ident) +
                                                         fw('%s<PixelTexture \n' % ident)))
                            fw(ident_step + 'repeatS="false"\n')
                            fw(ident_step + 'repeatT="false"\n')

                            fw(ident_step + 'image="%s 1 4 %s"\n' % (len(value), " ".join(value)))

                            fw(ident_step + '/>\n')

                            ident = ident[:-1]

                            fw('%s</field>\n' % ident)

                            # for i in range(0, 10, 4)
                            # value = ' '.join(['%d' % f for f in uniform['texpixels']])
                            # value = ' '.join(['%.6f' % (f / 256) for f in uniform['texpixels']])

                            # fw('%s<field name="%s" type="SFInt32" accessType="inputOutput" value="%s" />%s\n' % (ident, uniform['varname'], value, field_descr))
                            # print('test', len(uniform['texpixels']))
                    else:
                        assert (0)
                else:
                    print("SKIPPING", uniform['type'])

            file_frag = open(os.path.join(base_dst, shader_url_frag), 'w', encoding='utf-8')
            file_frag.write(gpu_shader['fragment'])
            file_frag.close()
            # patch it
            h3d_shader_glsl_frag_patch(os.path.join(base_dst, shader_url_frag),
                                       scene,
                                       frag_vars,
                                       frag_uniform_var_map,
                                       )

            file_vert = open(os.path.join(base_dst, shader_url_vert), 'w', encoding='utf-8')
            file_vert.write(gpu_shader['vertex'])
            file_vert.close()

            fw('%s<ShaderPart type="FRAGMENT" url=%s />\n' % (ident, quoteattr(shader_url_frag)))
            fw('%s<ShaderPart type="VERTEX" url=%s />\n' % (ident, quoteattr(shader_url_vert)))
            ident = ident[:-1]

            fw('%s</ComposedShader>\n' % ident)

    def writeImageTexture(ident, imageTextureNode):
        image=imageTextureNode.image
        image_id = quoteattr(unique_name(image, IM_ + image.name, uuid_cache_image, clean_func=clean_def, sep="_"))
        logger.info("write ImageTexture X3D node for %r format %r filepath %r" % (image.name, image.file_format, image.filepath ))



        if image.tag:
            fw('%s<ImageTexture USE=%s />\n' % (ident, image_id))
        else:
            image.tag = True

            ident_step = ident + (' ' * (-len(ident) +
                                         fw('%s<ImageTexture ' % ident)))
            fw('DEF=%s\n' % image_id)

            if (path_mode != 'COPY') and not image.filepath :
                # this is the case where the path_mode choice is intended to
                # reference an existing image file, but no filepath for that
                # file is specified in the image data structure
                logger.warning("no filepath available for Path Mode %s" % path_mode )

            # setting COPY_SUBDIR to None in calls to
            # bpy_extras.io_utils.path_reference will cause copied images
            # to be placed in same directory as the exported X3D file.
            COPY_SUBDIR=None
            has_packed_file =   image.packed_file and image.packed_file.size > 0
            if path_mode == 'COPY' and ( has_packed_file or not image.filepath) :
                # write to temporary folder so that
                # bpy_extras.io_utils.path_reference_copy can
                # copy it final  location at end of export
                use_file_format = image.file_format or 'PNG'

                try:
                    image_ext = {'JPEG':'.jpg' , 'PNG':'.png'}[use_file_format]
                except KeyError:
                    # if image data not in JPEG or PNG it is not supported in
                    # X3D standard. If image file_format is "FFMPEG" that is a movie
                    # format, and would be referenced in an X3D MovieTexture node
                    if use_file_format == "FFMPEG" :
                        logger.warning("movie textures not supported for X3D export")
                    else:
                        logger.warning("image texture file format %r not supported" % use_file_format)
                else:
                    image_base = os.path.splitext( os.path.basename(image.name))[0]
                    image_filename = image_base + image_ext

                    filepath_full = os.path.join(temporary_image_directory, image_filename)

                    logger.info("writing image for texture to %s" % filepath_full)
                    image.save( filepath = filepath_full )

                    filepath_ref = bpy_extras.io_utils.path_reference(
                                    filepath_full,
                                    temporary_image_directory,
                                    base_dst,
                                    path_mode,
                                    COPY_SUBDIR,
                                    copy_set,
                                    image.library)
            else:
                filepath = image.filepath
                filepath_full = bpy.path.abspath(filepath, library=image.library)
                filepath_ref = bpy_extras.io_utils.path_reference(
                                filepath_full,
                                base_src,
                                base_dst,
                                path_mode,
                                COPY_SUBDIR,
                                copy_set,
                                image.library)

            # following replaces Windows filepath separator with slash separator
            # for relative urls
            filepath_ref = filepath_ref.replace("\\", "/")

            image_urls =  [ filepath_ref ]

            logger.info("node urls: %s" % (image_urls,))
            fw(ident_step + "url='%s'\n" % ' '.join(['"%s"' % escape(f) for f in image_urls]))

            # default value of repeatS, repeatT fields is true, so only need to
            # specify if extension value is CLIP
            x3d_supported_extension = ["CLIP", "REPEAT"]
            if imageTextureNode.extension not in x3d_supported_extension:
                logger.warning("imageTextureNode.extension value %s unsupported in X3D" % imageTextureNode.extension)

            if imageTextureNode.extension == "CLIP":
                fw(ident_step + "repeatS='false' repeatT='false'")
            fw(ident_step + '/>\n')

    def writeBackground(ident, world):

        if world is None:
            return

        # note, not re-used
        world_id = quoteattr(unique_name(world, WO_ + world.name, uuid_cache_world, clean_func=clean_def, sep="_"))

        # XXX World changed a lot in 2.8... For now do minimal get-it-to-work job.
        # ~ blending = world.use_sky_blend, world.use_sky_paper, world.use_sky_real

        # ~ grd_triple = clamp_color(world.horizon_color)
        # ~ sky_triple = clamp_color(world.zenith_color)
        # ~ mix_triple = clamp_color((grd_triple[i] + sky_triple[i]) / 2.0 for i in range(3))

        blending = (False, False, False)

        grd_triple = clamp_color(world.color)
        sky_triple = clamp_color(world.color)
        mix_triple = clamp_color((grd_triple[i] + sky_triple[i]) / 2.0 for i in range(3))

        ident_step = ident + (' ' * (-len(ident) +
                                     fw('%s<Background ' % ident)))
        fw('DEF=%s\n' % world_id)
        # No Skytype - just Hor color
        if blending == (False, False, False):
            fw(ident_step + 'groundColor="%.3f %.3f %.3f"\n' % grd_triple)
            fw(ident_step + 'skyColor="%.3f %.3f %.3f"\n' % grd_triple)
        # Blend Gradient
        elif blending == (True, False, False):
            fw(ident_step + 'groundColor="%.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (grd_triple + mix_triple))
            fw(ident_step + 'groundAngle="1.57"\n')
            fw(ident_step + 'skyColor="%.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (sky_triple + mix_triple))
            fw(ident_step + 'skyAngle="1.57"\n')
        # Blend+Real Gradient Inverse
        elif blending == (True, False, True):
            fw(ident_step + 'groundColor="%.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (sky_triple + grd_triple))
            fw(ident_step + 'groundAngle="1.57"\n')
            fw(ident_step + 'skyColor="%.3f %.3f %.3f, %.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (sky_triple + grd_triple + sky_triple))
            fw(ident_step + 'skyAngle="1.57, 3.14159"\n')
        # Paper - just Zen Color
        elif blending == (False, False, True):
            fw(ident_step + 'groundColor="%.3f %.3f %.3f"\n' % sky_triple)
            fw(ident_step + 'skyColor="%.3f %.3f %.3f"\n' % sky_triple)
        # Blend+Real+Paper - komplex gradient
        elif blending == (True, True, True):
            fw(ident_step + 'groundColor="%.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (sky_triple + grd_triple))
            fw(ident_step + 'groundAngle="1.57"\n')
            fw(ident_step + 'skyColor="%.3f %.3f %.3f, %.3f %.3f %.3f"\n' % (sky_triple + grd_triple))
            fw(ident_step + 'skyAngle="1.57"\n')
        # Any Other two colors
        else:
            fw(ident_step + 'groundColor="%.3f %.3f %.3f"\n' % grd_triple)
            fw(ident_step + 'skyColor="%.3f %.3f %.3f"\n' % sky_triple)

        for tex in bpy.data.textures:
            if tex.type == 'IMAGE' and tex.image:
                namemat = tex.name
                pic = tex.image
                basename = quoteattr(bpy.path.basename(pic.filepath))

                if namemat == 'back':
                    fw(ident_step + 'backUrl=%s\n' % basename)
                elif namemat == 'bottom':
                    fw(ident_step + 'bottomUrl=%s\n' % basename)
                elif namemat == 'front':
                    fw(ident_step + 'frontUrl=%s\n' % basename)
                elif namemat == 'left':
                    fw(ident_step + 'leftUrl=%s\n' % basename)
                elif namemat == 'right':
                    fw(ident_step + 'rightUrl=%s\n' % basename)
                elif namemat == 'top':
                    fw(ident_step + 'topUrl=%s\n' % basename)

        fw(ident_step + '/>\n')

    # -------------------------------------------------------------------------
    # Export Object Hierarchy (recursively called)
    # -------------------------------------------------------------------------
    def export_object(ident, obj_main_parent, obj_main, obj_children):
        matrix_fallback = mathutils.Matrix()
        world = scene.world
        derived_dict = create_derived_objects(depsgraph, [obj_main])
        derived = derived_dict.get(obj_main)

        if use_hierarchy:
            obj_main_matrix_world = obj_main.matrix_world
            if obj_main_parent:
                obj_main_matrix = obj_main_parent.matrix_world.inverted(matrix_fallback) @ obj_main_matrix_world
            else:
                obj_main_matrix = obj_main_matrix_world
            obj_main_matrix_world_invert = obj_main_matrix_world.inverted(matrix_fallback)

            obj_main_id = quoteattr(unique_name(obj_main, obj_main.name, uuid_cache_object, clean_func=clean_def, sep="_"))

            ident = writeTransform_begin(ident, obj_main_matrix if obj_main_parent else global_matrix @ obj_main_matrix, suffix_quoted_str(obj_main_id, _TRANSFORM))

        # Set here just incase we dont enter the loop below.
        is_dummy_tx = False

        for obj, obj_matrix in (() if derived is None else derived):
            obj_type = obj.type

            if use_hierarchy:
                # make transform node relative
                obj_matrix = obj_main_matrix_world_invert @ obj_matrix
            else:
                obj_matrix = global_matrix @ obj_matrix

            # H3D - use for writing a dummy transform parent
            is_dummy_tx = False

            if obj_type == 'CAMERA':
                writeViewpoint(ident, obj, obj_matrix, scene)

                if use_h3d and scene.camera == obj:
                    view_id = uuid_cache_view[obj]
                    fw('%s<Transform DEF="%s">\n' % (ident, H3D_CAMERA_FOLLOW))
                    h3d_material_route.extend([
                        '<ROUTE fromNode="%s" fromField="totalPosition" toNode="%s" toField="translation" />' % (view_id, H3D_CAMERA_FOLLOW),
                        '<ROUTE fromNode="%s" fromField="totalOrientation" toNode="%s" toField="rotation" />' % (view_id, H3D_CAMERA_FOLLOW),
                    ])
                    is_dummy_tx = True
                    ident += '\t'

            elif obj_type in {'MESH', 'CURVE', 'SURFACE', 'FONT'}:
                if (obj_type != 'MESH') or (use_mesh_modifiers and obj.is_modified(scene, 'PREVIEW')):
                    obj_for_mesh = obj.evaluated_get(depsgraph) if use_mesh_modifiers else obj
                    try:
                        me = obj_for_mesh.to_mesh()
                    except:
                        me = None
                    do_remove = True
                else:
                    me = obj.data
                    do_remove = False

                if me is not None:
                    # ensure unique name, we could also do this by
                    # postponing mesh removal, but clearing data - TODO
                    if do_remove:
                        me_name_new = me_name_original = obj.name.rstrip("1234567890").rstrip(".")
                        count = 0
                        while me_name_new in mesh_name_set:
                            me_name_new = "%.17s.%03d" % (me_name_original, count)
                            count += 1
                        mesh_name_set.add(me_name_new)
                        mesh_name = me_name_new
                        del me_name_new, me_name_original, count
                    else:
                        mesh_name = me.name
                    # done

                    writeIndexedFaceSet(ident, obj, me, mesh_name, obj_matrix, world)

                    # free mesh created with to_mesh()
                    if do_remove:
                        obj_for_mesh.to_mesh_clear()

            elif obj_type == 'LIGHT':
                data = obj.data
                datatype = data.type
                if datatype == 'POINT':
                    writePointLight(ident, obj, obj_matrix, data, world)
                elif datatype == 'SPOT':
                    writeSpotLight(ident, obj, obj_matrix, data, world)
                elif datatype == 'SUN':
                    writeDirectionalLight(ident, obj, obj_matrix, data, world)
                else:
                    writeDirectionalLight(ident, obj, obj_matrix, data, world)
            else:
                # print "Info: Ignoring [%s], object type [%s] not handle yet" % (object.name,object.getType)
                pass

        # ---------------------------------------------------------------------
        # write out children recursively
        # ---------------------------------------------------------------------
        for obj_child, obj_child_children in obj_children:
            export_object(ident, obj_main, obj_child, obj_child_children)

        if is_dummy_tx:
            ident = ident[:-1]
            fw('%s</Transform>\n' % ident)
            is_dummy_tx = False

        if use_hierarchy:
            ident = writeTransform_end(ident)

    # -------------------------------------------------------------------------
    # Main Export Function
    # -------------------------------------------------------------------------
    def export_main():
        world = scene.world

        # tag un-exported IDs
        bpy.data.meshes.tag(False)
        bpy.data.materials.tag(False)
        bpy.data.images.tag(False)

        if use_selection:
            if use_active_collection:
                objects = [obj for obj in view_layer.active_layer_collection.collection.all_objects if obj.select_get()]
            else:
                objects = [obj for obj in view_layer.objects if obj.visible_get(view_layer=view_layer)
                            and obj.select_get(view_layer=view_layer)]
        else:
            if use_active_collection:
                objects = view_layer.active_layer_collection.collection.all_objects
            else:
                objects = [obj for obj in view_layer.objects]

        if use_visible:
            objects = tuple(obj for obj in objects if obj.visible_get())

        print('Info: starting X3D export to %r...' % file.name)
        ident = ''
        ident = writeHeader(ident)

        writeNavigationInfo(ident, scene, any(obj.type == 'LIGHT' for obj in objects))
        writeBackground(ident, world)
        writeFog(ident, world)

        ident = '\t\t'

        if use_hierarchy:
            objects_hierarchy = build_hierarchy(objects)
        else:
            objects_hierarchy = ((obj, []) for obj in objects)

        for obj_main, obj_main_children in objects_hierarchy:
            export_object(ident, None, obj_main, obj_main_children)

        ident = writeFooter(ident)

    export_main()

    # -------------------------------------------------------------------------
    # global cleanup
    # -------------------------------------------------------------------------
    file.close()

    if use_h3d:
        bpy.data.materials.remove(gpu_shader_dummy_mat)

    if copy_set:
        for c in copy_set:
            logger.info("copy_set item %r" % copy_set)
        bpy_extras.io_utils.path_reference_copy(copy_set)
    else:
        logger.info("no items in copy_set")

    print('Info: finished X3D export to %r' % file.name)


##########################################################
# Callbacks, needed before Main
##########################################################


def gzip_open_utf8(filepath, mode):
    """Workaround for py3k only allowing binary gzip writing"""

    import gzip

    # need to investigate encoding
    file = gzip.open(filepath, mode)
    write_real = file.write

    def write_wrap(data):
        return write_real(data.encode("utf-8"))

    file.write = write_wrap

    return file


def save(context,
         filepath,
         *,
         use_selection=True,
         use_active_collection=False,
         use_visible=False,
         use_mesh_modifiers=False,
         use_triangulate=False,
         use_normals=False,
         use_compress=False,
         use_hierarchy=True,
         use_h3d=False,
         global_matrix=None,
         path_mode='COPY',
         name_decorations=True
         ):

    logger.info("save: context %r to filepath %r" % (context,filepath))
    bpy.path.ensure_ext(filepath, '.x3dz' if use_compress else '.x3d')

    if bpy.ops.object.mode_set.poll():
        bpy.ops.object.mode_set(mode='OBJECT')

    if use_compress:
        file = gzip_open_utf8(filepath, 'w')
    else:
        file = open(filepath, 'w', encoding='utf-8')

    if global_matrix is None:
        global_matrix = mathutils.Matrix()

    export(file,
           global_matrix,
           context.evaluated_depsgraph_get(),
           context.scene,
           context.view_layer,
           use_mesh_modifiers=use_mesh_modifiers,
           use_selection=use_selection,
           use_active_collection=use_active_collection,
           use_visible=use_visible,
           use_triangulate=use_triangulate,
           use_normals=use_normals,
           use_hierarchy=use_hierarchy,
           use_h3d=use_h3d,
           path_mode=path_mode,
           name_decorations=name_decorations,
           )

    return {'FINISHED'}
