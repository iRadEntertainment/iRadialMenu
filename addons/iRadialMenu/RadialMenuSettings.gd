@tool
extends Resource
class_name RadialMenuSettings

enum SeparatorType{LINE, SECTOR}

#region exports Apperarance
@export_group("Appearance")
@export_range(-180.0, 180.0) var start_angle_offset: float = 0.0 # degrees
@export var first_item_centered := false
@export var bg_circle_color := Color("2a383baa")
@export var bg_full_circle: bool = false
@export_range(3, 1024, 1) var resolution: int = 64
@export var bg_texture: Texture2D

@export_subgroup("Dimensions", "dim_")
@export var dim_autosize := true
@export_range(0, 1024, 1) var dim_outer_radius: int = 384
@export var dim_center_offset := Vector2.ZERO
@export_range(0.0, 1.0, 0.01) var dim_inner_radius_ratio: float = 0.6

@export_subgroup("Highlight", "hover_")
@export var hover_color := Color("be3628")
@export var hover_child_modulate := Color("2a383b")
@export_range(0.1, 3.0, 0.001) var hover_size_factor: float = 1.0
@export_range(-1.0, 1.0, 0.001) var hover_radial_offset: float = 0.0

@export_subgroup("Reticle", "reticle_")
@export var reticle_outer_enabled := true
@export var reticle_inner_enabled := true
@export var reticle_separator_enabled := true
@export_range(1, 1024) var reticle_outer_width: int = 6
@export_range(1, 512) var reticle_inner_width: int = 6
@export_range(1, 256) var reticle_separator_width: int = 6
@export var reticle_separator_type: SeparatorType = SeparatorType.LINE
@export var reticle_outer_color := Color("be3628")
@export var reticle_inner_color := Color("be3628")
@export var reticle_separator_color := Color("be3628")
@export var reticle_antialiased := true

@export_subgroup("Items", "item_")
@export var item_align := false
@export var item_auto_size := false
@export_range(1, 1024, 1) var item_size: int = 48
@export_range(0, 2, 0.001) var item_auto_size_factor: float = 1.0
@export var item_offset := Vector2.ZERO
@export var item_modulate := Color.WHITE

@export_subgroup("Preview", "preview_")
@export var preview_show := true
@export_range(0.01, 2.0, 0.01) var preview_size_factor: float = 0.8
@export var preview_font: Font:
	get():
		if preview_font: return preview_font
		return EditorInterface.get_editor_theme().default_font
@export_range(4, 72, 1) var preview_font_size_name: int = 26
@export_range(4, 72, 1) var preview_font_size_description: int = 22
@export var preview_font_color_name: Color = Color.WHITE
@export var preview_font_color_description: Color = Color.WHITE
#endregion

#region exports Input
@export_group("Input")
@export var select_action_name := "ui_select"
#@export var focus_action_name := ""
#@export var focus_action_hold_mode := true
#@export var center_element_action_name := ""
@export var action_released := true
#@export var one_shot := false
@export var move_forward_action_name := ""
@export var move_left_action_name := ""
@export var move_back_action_name := ""
@export var move_right_action_name := ""

@export_subgroup("Mouse")
@export var keep_selection_outside := false

@export_subgroup("Controller")
@export var controller_enabled := false
@export_range(0.0, 1.0, 0.01) var controller_deadzone: float = 0.0
#endregion
