# Editor Interface helper script
# to access editor only features to have the preview for the RadialMenu's nodes

extends Node


static func get_editor_viewport_3d() -> Viewport:
	return EditorInterface.get_editor_viewport_3d()

static func get_edited_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()

static func get_node_3d_editor() -> Node:
	return EditorInterface.get_editor_main_screen().get_child(1)
