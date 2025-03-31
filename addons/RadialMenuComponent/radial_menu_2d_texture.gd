extends Control



# those inputs are passed from radial_menu_component.gd
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		pass


func _on_radial_menu_advanced_slot_selected(slot: Control, index: int) -> void:
	print(slot, index)


func _on_radial_menu_advanced_selection_changed(new_selection: int) -> void:
	print(new_selection)
