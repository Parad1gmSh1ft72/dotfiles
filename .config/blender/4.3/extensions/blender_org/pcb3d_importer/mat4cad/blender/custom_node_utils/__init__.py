import bpy
import nodeitems_utils

def setup_node_tree(node_tree: bpy.types.NodeTree, nodes_def, label_nodes=True):
    nodes = node_tree.nodes
    links = node_tree.links

    if not isinstance(nodes_def, dict):
        raise TypeError(f"nodes_def has type '{type(nodes_def).__name__}', expected 'dict'")
    for name, (node_type, attrs, inputs) in nodes_def.items():
        node = nodes.new(node_type)
        node.name = name
        if label_nodes:
            node.label = " ".join((word.capitalize() for word in name.split("_")))

        if not isinstance(attrs, dict):
            raise TypeError(f"{attrs} has type '{type(attrs).__name__}', expected 'dict'")
        for attr, value in attrs.items():
            setattr(node, attr, value)

        if not isinstance(inputs, dict):
            raise TypeError(f"{inputs} has type '{type(inputs).__name__}', expected 'dict'")
        for input_index, value in inputs.items():
            if isinstance(value, tuple):
                try:
                    from_node, output_index = value
                except ValueError:
                    raise ValueError(f"failed to unpack '{value}', expected '(node, index)'")
                links.new(nodes[from_node].outputs[output_index], node.inputs[input_index])
            else:
                node.inputs[input_index].default_value = value

class CustomNodetreeNodeBase:
    def init_node_tree(self, inputs_def, nodes_def, outputs_def):
        name = f"CUSTOM_NODE_{self.__class__.__name__}"
        node_tree = bpy.data.node_groups.new(name, "ShaderNodeTree")
        nodes = node_tree.nodes
        links = node_tree.links
        interface = node_tree.interface

        for name, (socket_type, attrs) in inputs_def.items():
            socket = interface.new_socket(name, in_out="INPUT", socket_type=socket_type)

            if not isinstance(attrs, dict):
                raise TypeError(f"{attrs} has type '{type(attrs).__name__}', expected 'dict'")
            for attribute, value in attrs.items():
                setattr(socket, attribute, value)

        node_input = nodes.new("NodeGroupInput")
        node_input.name = "inputs"

        setup_node_tree(node_tree, nodes_def)

        node_output = nodes.new("NodeGroupOutput")
        node_output.name = "outputs"

        for name, (socket_type, attrs, value) in outputs_def.items():
            socket = interface.new_socket(name, in_out="OUTPUT", socket_type=socket_type)

            if not isinstance(attrs, dict):
                raise TypeError(f"{attrs} has type '{type(attrs).__name__}', expected 'dict'")
            for attribute, value in attrs.items():
                setattr(socket, attribute, value)

            if isinstance(value, tuple):
                from_node, output_index = value
                links.new(nodes[from_node].outputs[output_index], node_output.inputs[name])
            else:
                node_output.inputs[name].default_value = value

        self.node_tree = node_tree

    def copy(self, node):
        self.node_tree = node.node_tree.copy()

    def free(self):
        if self.node_tree.users < 1:
            bpy.data.node_groups.remove(self.node_tree)

    def draw_buttons(self, context, layout):
        for prop in self.bl_rna.properties:
            if prop.is_runtime and not prop.is_readonly:
                text = "" if prop.type == "ENUM" else prop.name
                layout.prop(self, prop.identifier, text=text)

class SharedCustomNodetreeNodeBase(CustomNodetreeNodeBase):
    def init_node_tree(self, inputs_def, nodes_def, outputs_def):
        name = f"CUSTOM_NODE_{self.__class__.__name__}"
        if node_tree := bpy.data.node_groups.get(name):
            self.node_tree = node_tree
        else:
            super().init_node_tree(inputs_def, nodes_def, outputs_def)

    def copy(self, node):
        self.node_tree = node.node_tree
