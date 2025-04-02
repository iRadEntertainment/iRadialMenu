# Script edited from "Advanced Radial Menu" by "ortyrx"
# https://github.com/diklor/advanced_radial_menu
# Edit author Dario "iRad" De Vita

@tool
@icon("icon_radial_2d.svg")
class_name RadialMenu2D extends Control

enum SeparatorType{LINE, SECTOR}
const ANGLE_OFFSET: float = PI/2.0

#=======================================
@export var items: Array[RadialMenuItem] = []
#=======================================


@export var engine_preview := true: set = _set_engine_preview

@export_group("Appearance")
@export var first_item_centered := false
@export var slots_offset: int = 0
@export var circle_color := Color("2a383b")
@export var circle_fill: bool = false
@export_range(2, 1024, 1) var resolution: int = 96

@export_subgroup("Dimensions", "dim_")
@export var dim_autosize := true:
	set(val):
		dim_autosize = val
		dim_outer_radius = _get_auto_circle_radius()
		notify_property_list_changed()
@export_range(0, 1024, 1) var dim_outer_radius: int = 384
@export var dim_center_offset := Vector2.ZERO
@export_range(0.0, 1.0, 0.01) var dim_inner_radius_ratio: float = 0.6

@export_subgroup("Highlight", "hover_")
@export var hover_color := Color("be3628")
@export var hover_child_modulate := Color("2a383b")
@export_range(-1024, 1024, 1) var hover_offset_start: int = 0
@export_range(-1024, 1024, 1) var hover_offset_end: int = 0
@export_range(0.1, 3.0, 0.001) var hover_size_factor: float = 1.0
@export var hover_offset := Vector2.ZERO
@export_range(-10, 10) var hover_children_radial_offset: float = 0.0

@export_subgroup("Reticle", "reticle_")
@export var reticle_outer_enabled := true
@export var reticle_inner_enabled := true
@export var reticle_separator_enabled := true
@export_range(-1024, 1024) var reticle_outer_width: int = 6
@export_range(1, 512) var reticle_inner_width: int = 6
@export_range(1, 256) var reticle_separator_width: int = 6
@export var reticle_separator_type: SeparatorType = SeparatorType.LINE
@export var reticle_outer_color := Color("be3628")
@export var reticle_inner_color := Color("be3628")
@export var reticle_separator_color := Color("be3628")
@export var reticle_antialiased := true

@export_subgroup("Items", "item_")
@export_range(1, 1024, 1) var item_size: int = 48
@export var item_auto_size := false
@export_range(0, 2, 0.1) var item_auto_size_factor: float = 1.0
@export var item_offset := Vector2.ZERO
@export var item_align := false: set = _set_children_rotate
@export var item_modulate := Color.WHITE: set = _set_children_modulate
#@export var children_offsets_array := PackedVector2Array([])

@export_group("Input")
@export var select_action_name := "ui_select"
@export var focus_action_name := ""
@export var focus_action_hold_mode := true
@export var center_element_action_name := ""
@export var action_released := false
@export var one_shot := false

@export_subgroup("Mouse")
@export var keep_selection_outside := true

@export_subgroup("Controller")
@export var controller_enabled := false
@export_range(0.0, 1.0, 0.01) var controller_deadzone: float = 0.0
@export var move_forward_action_name := "move_forward"
@export var move_left_action_name := "move_left"
@export var move_back_action_name := "move_back"
@export var move_right_action_name := "move_right"
# controller works only when running
#If you hold / pressed this action, the controller will work. For example, Button 7 or 8
#Leave empty to always work
#Hold "focus_action_name" or just toggle. Works only if "focus_action_name" is not empty
#Select center element by pressing action (Works only if "first_item_centered" is engine_preview)

@export_group("Animated Pulse", "animated_pulse_")
@export var animated_pulse_enabled := false
@export_range(-250, 256, 1) var animated_pulse_intensity: int = 5
@export_range(-250, 256, 1) var animated_pulse_offset: int = 0
@export_range(-56, 56, 1) var animated_pulse_speed: int = 10
@export var animated_pulse_color := Color.WHITE


var viewport_size := Vector2.ZERO

var selection: int = -2 #0 first child, -1 center child,  -2 none
var item_count: int = 0
var child_nodes: Array[Control] = []
var tick: float = 0.0

var line_rotation_offset: int = 0
var center := Vector2.ZERO
var dim_inner_radius: float
var item_angle_full: float
var item_angle_gap: float
var item_angle_net: float

var _temporary_selection: int = -2
var _is_editor := true
var _is_focus_action_pressed := false


signal slot_selected(slot: Control, index: int)
signal selection_changed(new_selection: int)
signal selection_canceled


#region Init
func _ready() -> void:
	viewport_size = get_viewport().size
	_is_editor = Engine.is_editor_hint()
	gui_input.connect(_gui_input)
#endregion


#region Input
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.is_pressed() or selection == -2:
			return
		select()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		emit_signal("selection_canceled")
	
	if !select_action_name.is_empty() \
			and (event.is_action_released(select_action_name) if action_released else event.is_action_pressed(select_action_name)): 
		if selection != -2:
			select()
#endregion


#region Update
func _get_references() -> void:
	child_nodes.clear()
	item_count = 0
	for node: Node in get_children():
		if node is Control and node.visible:
			item_count += 1
			child_nodes.append(node)
	
	if first_item_centered and (item_count > 0):
		item_count -= 1


func _calculate_size_values() -> void:
	center = (size / 2.0) + dim_center_offset
	if dim_autosize:
		dim_outer_radius = _get_auto_circle_radius()
	dim_inner_radius = int(dim_outer_radius * dim_inner_radius_ratio)
	dim_inner_radius = clamp(dim_inner_radius, 4, dim_outer_radius - (reticle_outer_width + reticle_inner_width) )
	item_angle_full = TAU/item_count
	item_angle_gap = reticle_separator_width / dim_inner_radius
	item_angle_net = item_angle_full - item_angle_gap
	line_rotation_offset = deg_to_rad((360.0 / float(item_count)) * slots_offset)


func _draw() -> void:
	_get_references()
	_calculate_size_values()
	
	# draw background
	if first_item_centered:
		draw_circle(center, dim_outer_radius, circle_color)
	else:
		draw_doughnut(center, dim_outer_radius, dim_inner_radius, resolution, circle_color)
	
	# draw highlight center
	if (selection == -1 and first_item_centered):
		draw_circle(center, dim_inner_radius, hover_color)
	
	# draw highlight radial
	for i: int in item_count:
		var angle := i * item_angle_full - ANGLE_OFFSET # ANGLE_OFFSET is magic expression that fixes unaligned circle division
		angle += line_rotation_offset
		
		var start_rads: float = (i - 1) * item_angle_full + ANGLE_OFFSET - line_rotation_offset
		var end_rads: float = i * item_angle_full + ANGLE_OFFSET - line_rotation_offset
		
		var mid_rads: float = -(start_rads + end_rads) / 2.0
		var radius_mid: float = (dim_inner_radius + dim_outer_radius) / 2.0
		
		
		var draw_pos: Vector2 = Vector2.from_angle(mid_rads) * radius_mid
		if (selection == i and selection >= 0):
			draw_pos *= (1.0 + hover_children_radial_offset)
			draw_pos += hover_offset
		
		
		if (dim_inner_radius < dim_outer_radius) and (selection == i):
			if (item_count == 1):
				draw_circle(center, dim_outer_radius, hover_color)
			else:
				var points_per_arc: int = resolution
				var points_inner := PackedVector2Array()
				var points_outer := PackedVector2Array()
				
				for j: int in points_per_arc+1:
					var point_angle: float = (start_rads + j * (end_rads - start_rads) / float(points_per_arc)) 
					points_inner.append(center + ((dim_inner_radius + hover_offset_start) * Vector2.from_angle(TAU - point_angle) * hover_size_factor))
					points_outer.append(center + ((dim_outer_radius + hover_offset_end) * Vector2.from_angle(TAU - point_angle) * hover_size_factor))
				
				points_outer.reverse()
				
				draw_polygon(
					points_inner + points_outer,
					[hover_color],
				)
		
		if first_item_centered:
			i += 1
		_update_item_icon_transform(i, draw_pos)
	
	if first_item_centered:
		_update_item_icon_transform(0, Vector2.ZERO)
	
	_draw_reticle()
	_draw_pulse()


func _draw_reticle() -> void:
	var arc_start_angle: float = 0
	var arc_end_angle: float = TAU
	
	if reticle_inner_enabled:
		draw_arc(
			center,
			dim_inner_radius + reticle_inner_width/2.0,
			arc_start_angle,
			arc_end_angle,
			resolution,
			reticle_inner_color,
			reticle_inner_width,
			reticle_antialiased
		)
	
	if reticle_outer_enabled:
		draw_arc(
			center,
			dim_outer_radius - reticle_outer_width/2.0,
			arc_start_angle,
			arc_end_angle,
			resolution,
			reticle_outer_color,
			reticle_outer_width,
			reticle_antialiased
		)
	if reticle_separator_enabled:
		match reticle_separator_type:
			SeparatorType.LINE:
				for i in item_count:
					var point := Vector2.from_angle(i * item_angle_full - ANGLE_OFFSET)
					draw_line(
						center + point * (dim_inner_radius + reticle_inner_width/2.0),
						center + point * (dim_outer_radius - reticle_outer_width/2.0),
						reticle_separator_color,
						reticle_separator_width,
						reticle_antialiased
					)
			SeparatorType.SECTOR:
				var res: int = int(resolution/item_count)
				for i in item_count:
					var angle_center = i * item_angle_full - ANGLE_OFFSET
					var poly: PackedVector2Array = get_sector_points(
						center,
						angle_center,
						item_angle_gap,
						dim_inner_radius,
						dim_outer_radius,
						res
					)
					draw_polygon(poly, [reticle_separator_color])

func _draw_pulse() -> void:
	if !animated_pulse_enabled:
		return
	if tick > 100.0:
		tick = 0.0
	
	draw_arc(
		center,
		(
			dim_outer_radius - animated_pulse_offset + \
			animated_pulse_intensity + \
			sin(tick * animated_pulse_speed) * \
			animated_pulse_intensity
		),
		0,
		TAU,
		resolution,
		animated_pulse_color,
		reticle_inner_width,
		reticle_antialiased
	)


func _update_item_icon_transform(i: int, radial_position_offset := Vector2.ZERO) -> void:
	var child: Control = (child_nodes[i] if i <= child_nodes.size() else null) # Control?
	if child != null:
		if item_count == 1:
			if first_item_centered and !child.name.begins_with("__"): #ignore child_nodes with __ prefix
				radial_position_offset = Vector2(0, dim_outer_radius / 2.0)
			else:
				radial_position_offset = Vector2.ZERO
		
		var factor := 1.0
		if item_auto_size:
			factor = (dim_outer_radius / (item_size * 1.5)) * item_auto_size_factor
		
		child._set_size.call_deferred(Vector2.ONE * item_size * factor)
		child.position = (center - (child.size / 2.0)) + radial_position_offset + item_offset
		if child.has_meta("radial_offset"):
			child.position += child.get_meta("radial_offset", Vector2.ZERO)
		#if children_offsets_array.size() - 1 >= i:
			#child.position += children_offsets_array[i]
		
		child.pivot_offset = child.size / 2.0
		
		if item_align:
			child.rotation_degrees = 360 - (360 * int(i / float(item_count)))


func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if animated_pulse_enabled:
		tick = wrapf(tick + delta, 0.0, TAU * animated_pulse_intensity)
	
	var pos_offset: Vector2 = viewport_size - (size + position)
	var size_offset: Vector2 = (viewport_size / 2.0 - (center - dim_center_offset))
	var pointer_pos := -Vector2.ONE #not Vector2.ZERO because mouse can be in that position
	var controller_pressed := false
	
	if _temporary_selection != -2:
		selection = clampi(_temporary_selection, -1, item_count - 1)
		queue_redraw()
		return
	
	#if mouse_enabled:
	pointer_pos = (get_global_mouse_position() - viewport_size / 2.0) - size_offset + pos_offset - dim_center_offset
	if controller_enabled and !_is_editor: #controller works only when running, otherwise spams with errors
		controller_pressed = true
		if !focus_action_name.is_empty():
			if !focus_action_hold_mode:
				if Input.is_action_just_pressed(focus_action_name):
					_is_focus_action_pressed = not _is_focus_action_pressed
				controller_pressed = _is_focus_action_pressed
			else:
				controller_pressed = Input.is_action_pressed(focus_action_name)
		
		if controller_pressed:
			var controller_vector := Vector2(
				Input.get_action_strength(move_right_action_name) - Input.get_action_strength(move_left_action_name),
				Input.get_action_strength(move_back_action_name) - Input.get_action_strength(move_forward_action_name)
			).limit_length(1.0) 
			
			if (controller_vector.length_squared() > controller_deadzone) \
				and !( focus_action_name.is_empty() and (controller_vector == Vector2.ZERO) ):
					pointer_pos = controller_vector * (dim_inner_radius + ((dim_outer_radius - dim_inner_radius) / 2.0))
			else:
				controller_pressed = false
		else:
			selection = -2
	
	if (pointer_pos != -Vector2.ONE):
		var mouse_radius: float = pointer_pos.length()
		var prev_selection := selection
		
		if (mouse_radius < dim_inner_radius):
			if first_item_centered and !controller_pressed:
				selection = -1
		elif !_is_editor and !center_element_action_name.is_empty() and Input.is_action_just_pressed(center_element_action_name):
			selection = -1
			select()
		
		elif !first_item_centered and item_count == 1:
			if mouse_radius < dim_outer_radius:
				selection = 0
		else:
			if keep_selection_outside or (!keep_selection_outside and mouse_radius <= dim_outer_radius):
				var mouse_rads: float = fposmod(-pointer_pos.angle() - ANGLE_OFFSET, TAU) + line_rotation_offset
				selection = wrap(
					ceil(
							(mouse_rads / TAU) * item_count
						),
					0,
					float(item_count)
				)
			elif (!keep_selection_outside and mouse_radius > dim_outer_radius):
				selection = -2
		
		if selection != prev_selection:
			if selection >= 0:
				for child in get_children():
					if child is Control:
						child.modulate = hover_child_modulate if child.get_index() == selection else item_modulate
			selection_changed.emit(selection)
	
	queue_redraw()
#endregion


#region Getters/Setters
func _get_auto_circle_radius() -> int:
	if size.x < size.y:
		return int(size.x / 2.0)
	return int(size.y / 2.0)


func _set_engine_preview(value: bool) -> void:
	engine_preview = value
	set_process(value)
	#set_process_unhandled_input(mouse_enabled if value else false)


func _set_mouse_enabled(value: bool) -> void:
	#mouse_enabled = value
	#set_process_unhandled_input(value)
	if !value:
		selection = -1


func _set_children_rotate(value: bool) -> void:
	item_align = value
	if !value:
		for v: Node in get_children():
			if v is Control and v.visible:
				v.rotation = 0


func _set_children_modulate(value: Color) -> void:
	item_modulate = value
	for child in get_children():
		if child is Control:
			child.modulate = item_modulate


func set_temporary_selection(value: int = -2) -> void:
	_temporary_selection = value
	for child in get_children():
		if child is Control:
			child.modulate = hover_child_modulate if child.get_index() == value else item_modulate
	selection_changed.emit(clampi(_temporary_selection, -1, item_count - 1))
#endregion


#region Utilities
func get_selection_at_position(_pos: Vector2) -> int: # TODO
	return -2


func get_selected_child() -> Node:
	return get_child(selection + (1 if first_item_centered else 0))


func select() -> void: #select currently hovered element
	if (selection == -2):
		selection_canceled.emit()
		return
	slot_selected.emit(get_selected_child(), selection)
	if one_shot:
		engine_preview = false
	selection = -2


func draw_doughnut(
			_center: Vector2,
			_outer_radius: int,
			_inner_radius: int,
			_resolution: int,
			_color: Color,
		) -> void:
	var _outer_poly := PackedVector2Array()
	var _inner_poly := PackedVector2Array()
	var point_angle: float = (TAU / float(_resolution)) 
	for i: int in _resolution + 1:
		var dir: Vector2 = Vector2.from_angle(point_angle * i)
		var p_in: Vector2 = _center + dir * _inner_radius
		var p_out: Vector2 = _center + dir * _outer_radius
		_inner_poly.append(p_in)
		_outer_poly.append(p_out)
	_outer_poly.reverse()
	var poly_top: PackedVector2Array = _inner_poly.slice(_resolution/2) + _outer_poly.slice(0, _resolution/2 + 1)
	var poly_bot: PackedVector2Array = _inner_poly.slice(0, _resolution/2 + 1) + _outer_poly.slice(_resolution/2)
	draw_polygon(poly_top, [_color])
	draw_polygon(poly_bot, [_color])


static func get_sector_points(
			_center: Vector2,
			_angle_center: float,
			_angle_width: float,
			_inner_radius: float,
			_outer_radius: float,
			_resolution: int,
		) -> PackedVector2Array:
	
	var half_width: float = _angle_width * 0.5
	var start_angle: float = _angle_center - half_width
	var end_angle: float = _angle_center + half_width
	
	var inner_p := PackedVector2Array()
	var outer_p := PackedVector2Array()
	
	for i in range(_resolution + 1):
		var t := float(i) / _resolution
		var angle := lerp(start_angle, end_angle, t)
		var dir := Vector2.from_angle(angle)
		inner_p.append(dir * _inner_radius + _center)
		outer_p.append(dir * _outer_radius + _center)
	
	outer_p.reverse()
	inner_p.append_array(outer_p)
	
	return inner_p
#endregion


#region Conditional properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "dim_outer_radius" and dim_autosize == true:
		property.usage |= PROPERTY_USAGE_READ_ONLY
#endregion
