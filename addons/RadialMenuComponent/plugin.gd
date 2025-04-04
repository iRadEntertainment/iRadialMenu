@tool
extends EditorPlugin

# Called when the plugin is enabled
func _enter_tree() -> void:
	# Add custom types
	add_custom_type(
		"RadialMenu2D",
		"Control",
		preload("RadialMenu2D.gd"),
		preload("icon_radial_2d.svg")
	)
	add_custom_type(
		"RadialMenu3DFlat",
		"Node3D",
		preload("RadialMenu3DFlat.gd"),
		preload("icon_radial_3d_2d.svg")
	)


# Called when the plugin is disabled
func _exit_tree() -> void:
	# Remove custom types
	remove_custom_type("RadialMenu2D")
	remove_custom_type("RadialMenu3DFlat")
