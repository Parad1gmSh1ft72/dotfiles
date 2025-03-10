# SPDX-FileCopyrightText: 2011-2024 Blender Foundation
#
# SPDX-License-Identifier: GPL-3.0-or-later

bl_info = {
    "name":"Web3D X3D/VRML2 format",
    "description": "Import-Export X3D, Import VRML2",
    "author": "maintainer: Bujus_Krachus",
    "version": (2, 4, 4),
    "blender": (4, 2, 0),
    "location": "",
    "warning": "",
    "doc_url": "",
    'tracker_url': "https://projects.blender.org/extensions/io_scene_x3d",
    'support': 'COMMUNITY',
    "category": "IO",
}
bl_info_copy = bl_info.copy()


if "bpy" in locals():
    import importlib

    if "import_x3d" in locals():
        importlib.reload(import_x3d)
    if "export_x3d" in locals():
        importlib.reload(export_x3d)

import bpy
from bpy.props import (
    BoolProperty,
    EnumProperty,
    FloatProperty,
    StringProperty,
    CollectionProperty,
)
from bpy_extras.io_utils import (
    ImportHelper,
    ExportHelper,
    orientation_helper,
    axis_conversion
)
from bpy.types import (
    Operator,
    OperatorFileListElement,
)
from bpy_extras.io_utils import (
    poll_file_object_drop,
)

from .translations import get_language, translate
from .prefs import X3D_Preferences

blender_version = bpy.app.version
blender_version_higher_279 = blender_version[0] > 2 or (blender_version[0] == 2 and blender_version[1] >= 79)

lang = get_language()

@orientation_helper(axis_forward='-Z', axis_up='Y')
class ImportX3D(bpy.types.Operator, ImportHelper):
    """Import an X3D or VRML2 file"""
    bl_idname = "import_scene.x3d"
    bl_label = translate(lang,"import")
    bl_options = {'PRESET', 'UNDO'}

    filename_ext = ".x3d"

    filter_glob: StringProperty(default="*.x3d;*.wrl", options={'HIDDEN'})

    files: CollectionProperty(
        name="File Path",
        type=OperatorFileListElement,
    )
    directory: StringProperty(
        subtype='DIR_PATH',
    )

    def _file_unit_update(self, context):
        if self.file_unit == 'CUSTOM':
            return
        UNITS_FACTOR = {'M': 1.0, 'DM': 0.1, 'CM': 0.01, 'MM': 0.001, 'IN': 0.0254}
        self.global_scale = UNITS_FACTOR[self.file_unit]

    file_unit: EnumProperty(
        name=translate(lang, "file_unit"),
        items=(('M', translate(lang, "meter"), translate(lang, "meter_description")),
               ('DM', translate(lang,"decimeter"), translate(lang, "decimeter_description")),
               ('CM', translate(lang, "centimeter"), translate(lang, "centimeter_description")),
               ('MM', translate(lang, "milimeter"), translate(lang, "milimeter_description")),
               ('IN', translate(lang, "inch"), translate(lang, "inch_description")),
               ('CUSTOM', translate(lang, "custom"), translate(lang, "custom_description")),
               ),
        description=translate(lang, "file_unit_description"),
        default='M',
        update=_file_unit_update,
    )

    global_scale: FloatProperty(
        name=translate(lang, "scale"),
        min=0.001, max=1000.0,
        default=1.0,
        precision=4,
        step=1.0,
        description=translate(lang, "scale_description"),
    )

    as_collection: BoolProperty(
        name=translate(lang, "as_collection"),
        description=translate(lang, "as_collection_description"),
        default=False,
    )

    solidify: BoolProperty(
        name=translate(lang, "solidify"),
        description=translate(lang, "solidify_description"),
        default=False,
    )

    solidify_value: FloatProperty(
        name=translate(lang, "solidify_value"),
        min=-10.0, max=10.0,
        default=0.1,
        precision=2,
        step=1.0,
        description=translate(lang, "solidify_value_description"),
    )

    def execute(self, context):
        from . import import_x3d

        keywords = self.as_keywords(ignore=("axis_forward",
                                            "axis_up",
                                            "file_unit",
                                            "filter_glob",
                                            ))
        global_matrix = axis_conversion(from_forward=self.axis_forward,
                                        from_up=self.axis_up,
                                        ).to_4x4()
        keywords["global_matrix"] = global_matrix

        return import_x3d.load(context, **keywords)

    def draw(self, context):
        pass


class X3D_PT_export_include(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Include"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "EXPORT_SCENE_OT_x3d"

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        sublayout = layout.column(heading="Limit to")
        sublayout.enabled = True
        sublayout.prop(operator, "use_selection")
        sublayout.prop(operator, "use_visible")
        sublayout.prop(operator, "use_active_collection")

        sublayout = layout.column(heading="Include data")
        sublayout.enabled = True
        sublayout.prop(operator, "use_hierarchy")
        sublayout.prop(operator, "name_decorations")
        # keeping h3d disabled for now as the underlying gpu.export_shader() got removed since 2.80
        # see https://projects.blender.org/blender/blender-addons/issues/79991 for details
        # when readding it, don't forget to change the description
        # layout.prop(operator, "use_h3d")
        col = layout.column()
        col.enabled = not blender_version_higher_279
        col.prop(operator, "use_h3d")

class X3D_PT_export_external_resource(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Image Textures"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "EXPORT_SCENE_OT_x3d"

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "path_mode")

class X3D_PT_export_transform(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Transform"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "EXPORT_SCENE_OT_x3d"

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "file_unit")

        sub = layout.row()
        sub.enabled = operator.file_unit == 'CUSTOM'

        sub.prop(operator, "global_scale")
        layout.prop(operator, "axis_forward")
        layout.prop(operator, "axis_up")




class X3D_PT_export_geometry(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Geometry"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "EXPORT_SCENE_OT_x3d"

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "use_mesh_modifiers")
        layout.prop(operator, "use_triangulate")
        layout.prop(operator, "use_normals")
        layout.prop(operator, "use_compress")


@orientation_helper(axis_forward='-Z', axis_up='Y')
class ExportX3D(bpy.types.Operator, ExportHelper):
    """Export selection to Extensible 3D file (.x3d)"""
    bl_idname = "export_scene.x3d"
    bl_label = translate(lang, "export")
    bl_options = {'PRESET'}

    filename_ext = ".x3d"
    filter_glob: StringProperty(default="*.x3d", options={'HIDDEN'})

    use_selection: BoolProperty(
        name=translate(lang, "selection_only"),
        description=translate(lang, "selection_only_description"),
        default=False,
    )
    use_visible: BoolProperty(
        name=translate(lang, "visible_only"),
        description=translate(lang, "visible_only_description"),
        default=False,
    )
    use_active_collection: BoolProperty(
        name=translate(lang, "active_collection_only"),
        description=translate(lang, "active_collection_only_description"),
        default=False,
    )
    use_mesh_modifiers: BoolProperty(
        name=translate(lang, "apply_modifiers"),
        description=translate(lang, "apply_modifiers_description"),
        default=True,
    )
    use_triangulate: BoolProperty(
        name=translate(lang, "triangulate"),
        description=translate(lang, "triangulate_description"),
        default=False,
    )
    use_normals: BoolProperty(
        name=translate(lang, "normals"),
        description=translate(lang, "normals_description"),
        default=False,
    )
    use_compress: BoolProperty(
        name=translate(lang, "compress"),
        description=translate(lang, "compress_description"),
        default=False,
    )
    use_hierarchy: BoolProperty(
        name=translate(lang, "hierarchy"),
        description=translate(lang, "hierarchy_description"),
        default=True,
    )
    name_decorations: BoolProperty(
        name=translate(lang, "name_decorations"),
        description=translate(lang, "name_decorations_description"),
        default=True,
    )

    def _h3d_update(self, context):
        """Disable h3d permanently even if set programmatically"""
        if blender_version_higher_279:
            self.use_h3d = False
    use_h3d: BoolProperty(
        name=translate(lang, "h3d_extensions"),
        description=translate(lang, "h3d_extensions_description"),
        default=False,
        update=_h3d_update,
    )

    def _file_unit_update(self, context):
        if self.file_unit == 'CUSTOM':
            return
        UNITS_FACTOR = {'M': 1.0, 'DM': 10.0, 'CM': 100.0, 'MM': 1000.0, 'IN': 1.0 / 0.0254}
        self.global_scale = UNITS_FACTOR[self.file_unit]

    file_unit: EnumProperty(
        name=translate(lang, "file_unit"),
        items=(('M', translate(lang, "meter"), translate(lang, "meter_description")),
               ('DM', translate(lang, "decimeter"), translate(lang, "decimeter_description")),
               ('CM', translate(lang, "centimeter"), translate(lang, "centimeter_description")),
               ('MM', translate(lang, "milimeter"), translate(lang, "milimeter_description")),
               ('IN', translate(lang, "inch"), translate(lang, "inch_description")),
               ('CUSTOM', translate(lang, "custom"), translate(lang, "custom_description")),
               ),
        description=translate(lang, "file_unit_description"),
        default='M',
        update=_file_unit_update,
    )

    global_scale: FloatProperty(
        name="Scale",
        min=0.01, max=1000.0,
        default=1.0,
        precision=4,
        step=1.0,
        description=translate(lang, "scale_description"),
    )


    path_mode: EnumProperty(
        name=translate(lang, "path_mode_name"),
        description= translate(lang, "path_mode_description"),
        #   A subset of the items in bpy_extras.io_utils.path_reference_mode
        items=(
            ('RELATIVE', translate(lang,"relative_mode"), translate(lang, "relative_mode_description")),
            ('STRIP', translate(lang,"strip_mode"), translate(lang, "strip_mode_description")),
            ('COPY', translate(lang, "copy_mode"), translate(lang, "copy_mode_description")),
        ),
        default='COPY',
    )

    def execute(self, context):
        from . import export_x3d

        from mathutils import Matrix

        keywords = self.as_keywords(ignore=("axis_forward",
                                            "axis_up",
                                            "file_unit",
                                            "global_scale",
                                            "check_existing",
                                            "filter_glob",
                                            ))
        global_matrix = axis_conversion(to_forward=self.axis_forward,
                                        to_up=self.axis_up,
                                        ).to_4x4() @ Matrix.Scale(self.global_scale, 4)
        keywords["global_matrix"] = global_matrix

        return export_x3d.save(context, **keywords)

    def draw(self, context):
        pass


class X3D_PT_import_transform(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Transform"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "IMPORT_SCENE_OT_x3d"

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "file_unit")

        sub = layout.row()
        sub.enabled = operator.file_unit == 'CUSTOM'

        sub.prop(operator, "global_scale")
        layout.prop(operator, "axis_forward")
        layout.prop(operator, "axis_up")


class X3D_PT_import_general(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "General"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "IMPORT_SCENE_OT_x3d"


    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "as_collection")


class X3D_PT_import_mesh(bpy.types.Panel):
    bl_space_type = 'FILE_BROWSER'
    bl_region_type = 'TOOL_PROPS'
    bl_label = "Mesh"
    bl_parent_id = "FILE_PT_operator"

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator

        return operator.bl_idname == "IMPORT_SCENE_OT_x3d"


    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        sfile = context.space_data
        operator = sfile.active_operator

        layout.prop(operator, "solidify")
        sub = layout.row()
        sub.enabled = operator.solidify == True
        sub.prop(operator, "solidify_value")


class IO_FH_X3D(bpy.types.FileHandler):
    """File Handler for drag drop import of x3d files"""
    bl_idname = "IO_FH_x3d"
    bl_label = "x3d"
    bl_import_operator = "import_scene.x3d"
    bl_export_operator = "export_scene.x3d"
    bl_file_extensions = ".x3d;.wrl"

    @classmethod
    def poll_drop(cls, context):
        return poll_file_object_drop(context)


def menu_func_import(self, context):
    self.layout.operator(ImportX3D.bl_idname,
                         text="X3D Extensible 3D (.x3d/.wrl)")


def menu_func_export(self, context):
    self.layout.operator(ExportX3D.bl_idname,
                         text="X3D Extensible 3D (.x3d)")


classes = (
    ExportX3D,
    X3D_PT_export_include,
    X3D_PT_export_transform,
    X3D_PT_export_geometry,
    X3D_PT_export_external_resource,
    ImportX3D,
    X3D_PT_import_general,
    X3D_PT_import_transform,
    X3D_PT_import_mesh,
    IO_FH_X3D,
    X3D_Preferences
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)

    bpy.types.TOPBAR_MT_file_import.append(menu_func_import)
    bpy.types.TOPBAR_MT_file_export.append(menu_func_export)


def unregister():
    bpy.types.TOPBAR_MT_file_import.remove(menu_func_import)
    bpy.types.TOPBAR_MT_file_export.remove(menu_func_export)

    for cls in classes:
        bpy.utils.unregister_class(cls)


if __name__ == "__main__":
    register()
