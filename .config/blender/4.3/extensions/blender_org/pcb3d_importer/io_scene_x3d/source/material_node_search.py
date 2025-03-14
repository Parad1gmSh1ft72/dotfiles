# SPDX-FileCopyrightText: 2024 Vincent Marchetti
#
# SPDX-License-Identifier: GPL-3.0-or-later

import logging
_logger = logging.getLogger("export_x3d.material_node_search")

"""
functions implementing searching the node tree for Blender materials in search
of particular nodes enabling export of material properties into other formats
"""


# values of bl_idname for shader nodes to be located
# reference Python API list of subclasses of ShaderNode
# at https://docs.blender.org/api/current/bpy.types.ShaderNode.html#bpy.types.ShaderNode
class _ShaderNodeTypes:
    MATERIAL_OUTPUT=  "ShaderNodeOutputMaterial"
    BSDF_PRINCIPLED = "ShaderNodeBsdfPrincipled"
    IMAGE_TEXTURE   = "ShaderNodeTexImage"


def _find_node_by_idname(nodes, idname):
    """
    nodes a sequence of Nodes, idname a string
    Each node assumed to ne an instance of Node(bpy_struct)
    https://docs.blender.org/api/current/bpy.types.Node.html

    The idname is searched for in the Node instance member bl_idname
    https://docs.blender.org/api/current/bpy.types.Node.html#bpy.types.Node.bl_idname
    and is generally some string version of the name of the subclass

    See https://docs.blender.org/api/current/bpy.types.ShaderNode.html for list of
    ShaderNode subclasses

    returns first matching node found,returns None if no matching nodes
    prints warning if multiple matches found
    """
    _logger.debug("enter _find_node_by_idname search for %s in %r" % (idname, nodes))
    nodelist = [nd for nd in nodes if nd.bl_idname == idname]
    _logger.debug("result _find_node_by_idname found %i" % len(nodelist))
    if len(nodelist) == 0:
        return None
    if len(nodelist) > 1:
        _logger.warn("_find_node_by_idname : multiple (%i) nodes of type %s found" % (len(nodelist), idname))
    return nodelist[0]

def imageTexture_in_material(material):
    """
    Identifies ImageTexture node used as the input to Base Color attribute of BSDF node.
    Does not search for images used as textures inside a NodeGrouo node.

    argument material an instance of Material(ID)
    https://docs.blender.org/api/current/bpy.types.Material.html

    returns instance of ShaderNodeTexImage
    https://docs.blender.org/api/current/bpy.types.ShaderNodeTexImage.html
    """
    _logger.debug("evaluating image in material %s" % material.name)

    material_output = _find_node_by_idname( material.node_tree.nodes, _ShaderNodeTypes.MATERIAL_OUTPUT)
    if material_output is None:
        _logger.warn("%s not found in material %s" % (_ShaderNodeTypes.MATERIAL_OUTPUT, material.name))
        return None

    SURFACE_ATTRIBUTE= "Surface"
    bsdf_principled =  _find_node_by_idname(
        [ndlink.from_node for ndlink in  material_output.inputs.get(SURFACE_ATTRIBUTE).links],
        _ShaderNodeTypes.BSDF_PRINCIPLED)
    if bsdf_principled is None :
        return None

    BASE_COLOR_ATTRIBUTE      = 'Base Color'
    image_texture = _find_node_by_idname(
        [ndlink.from_node for ndlink in  bsdf_principled.inputs.get(BASE_COLOR_ATTRIBUTE).links],
        _ShaderNodeTypes.IMAGE_TEXTURE )
    if image_texture is None:
        return None
    _logger.debug("located image texture node %r" % image_texture)
    return image_texture

