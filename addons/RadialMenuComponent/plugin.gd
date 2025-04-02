@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("RadialMenu2D", "Control", preload("RadialMenu2D.gd"), preload("icon_radial_2d.svg"))
	add_custom_type("RadialMenu3DFlat", "Control", preload("RadialMenu3DFlat.gd"), preload("icon_radial_3d_2d.svg"))


func _exit_tree():
	remove_custom_type("RadialMenu2D")
	remove_custom_type("RadialMenu3DFlat")
