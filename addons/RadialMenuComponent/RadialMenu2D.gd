# Script based on the work from "Advanced Radial Menu" by "ortyrx"
# https://github.com/diklor/advanced_radial_menu
# Edit author Dario "iRad" De Vita

@tool
@icon("icon_radial_2d.svg")
class_name RadialMenu2D extends Control

@export var engine_preview := true: set = _set_engine_preview
@export var items: Array[RadialMenuItem] = []
@export var settings := RadialMenuSettings.new()

#region Functional variables
var selected_idx: int = -1

var start_angle_offset_radiants: float
var center := Vector2.ZERO
var dim_inner_radius: float
var item_pos_radius: float # center position for items
var items_radial_count: int
var sector_angle_full: float
var sector_angle_gap: float
var sector_angle_net: float
var sector_resolution: int

var _is_editor := true
var _is_focus_action_pressed := false
#endregion

#region Signals
signal slot_selected(selected_idx: int)
signal selection_changed(selected_idx: int)
signal selection_canceled
#endregion


#region Init
func _ready() -> void:
	_is_editor = Engine.is_editor_hint()
	gui_input.connect(_gui_input)
	await get_tree().process_frame
	queue_redraw()
#endregion


#region Input
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.is_pressed() or selected_idx == -1:
			return
		select()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		selection_canceled.emit()
	
	if !settings.select_action_name.is_empty():
		var is_select_input: bool = event.is_action_released(settings.select_action_name) and settings.action_released
		is_select_input = (event.is_action_pressed(settings.select_action_name) and !settings.action_released) or is_select_input
		if is_select_input:
			select()
#endregion


#region Update
func update() -> void:
	if items.is_empty(): return
	_calculate_size_values()
	queue_redraw()


func _calculate_size_values() -> void:
	# main circle
	center = (size / 2.0) + settings.dim_center_offset
	if settings.dim_autosize:
		settings.dim_outer_radius = _get_auto_circle_radius()
	dim_inner_radius = int(settings.dim_outer_radius * settings.dim_inner_radius_ratio)
	dim_inner_radius = clamp(dim_inner_radius, 4, settings.dim_outer_radius - (settings.reticle_outer_width + settings.reticle_inner_width) )
	start_angle_offset_radiants = deg_to_rad(settings.start_angle_offset)
	
	# sectors
	items_radial_count = items.size() if !settings.first_item_centered else items.size() - 1
	sector_angle_full = TAU/items_radial_count
	sector_resolution = max(int(settings.resolution / items_radial_count), 2)
	
	sector_angle_gap = settings.reticle_separator_width / dim_inner_radius
	sector_angle_net = sector_angle_full - sector_angle_gap
	
	# items
	var doughnut_width_full: float = settings.dim_outer_radius - dim_inner_radius
	var doughnut_width_net: float = doughnut_width_full - settings.reticle_inner_width - settings.reticle_outer_width
	item_pos_radius = dim_inner_radius + settings.reticle_inner_width + doughnut_width_net / 2.0


func _draw() -> void:
	if items.is_empty(): return
	
	_draw_background()
	_draw_reticle()
	_draw_highlight()
	_draw_icons()


func _draw_background() -> void:
	if settings.first_item_centered or settings.bg_full_circle:
		draw_circle(center, settings.dim_outer_radius, settings.bg_circle_color, true, -1, settings.reticle_antialiased)
	elif settings.bg_texture:
		for i in items_radial_count:
			var angle_center_selected: float = i * sector_angle_full + sector_angle_full/2.0 + start_angle_offset_radiants
			var poly: PackedVector2Array = get_sector_points(
				center,
				angle_center_selected,
				sector_angle_net,
				dim_inner_radius,
				settings.dim_outer_radius,
				sector_resolution
			)
			var uv_poly: PackedVector2Array = uv_from_sector_poly(poly.size())
			draw_polygon(poly, [settings.bg_circle_color], uv_poly, settings.bg_texture)
	elif settings.reticle_separator_type == RadialMenuSettings.SeparatorType.SECTOR and !settings.reticle_separator_enabled:
		for i in items_radial_count:
			var angle_center_selected: float = i * sector_angle_full + sector_angle_full/2.0 + start_angle_offset_radiants
			var poly: PackedVector2Array = get_sector_points(
				center,
				angle_center_selected,
				sector_angle_net,
				dim_inner_radius,
				settings.dim_outer_radius,
				sector_resolution
			)
			draw_polygon(poly, [settings.bg_circle_color])
	else:
		# draw a doughnut
		var poly_right: PackedVector2Array = get_sector_points(
			center, 0, PI, dim_inner_radius, settings.dim_outer_radius, int(settings.resolution/2)
		)
		var poly_left: PackedVector2Array = get_sector_points(
			center, PI, PI, dim_inner_radius, settings.dim_outer_radius, int(settings.resolution/2)
		)
		draw_polygon(poly_right, [settings.bg_circle_color])
		draw_polygon(poly_left, [settings.bg_circle_color])


func _draw_reticle() -> void:
	var arc_start_angle: float = 0
	var arc_end_angle: float = TAU
	
	if settings.reticle_inner_enabled:
		draw_arc(
			center,
			dim_inner_radius + settings.reticle_inner_width/2.0,
			arc_start_angle,
			arc_end_angle,
			settings.resolution,
			settings.reticle_inner_color,
			settings.reticle_inner_width,
			settings.reticle_antialiased
		)
	
	if settings.reticle_outer_enabled:
		draw_arc(
			center,
			settings.dim_outer_radius - settings.reticle_outer_width/2.0,
			arc_start_angle,
			arc_end_angle,
			settings.resolution,
			settings.reticle_outer_color,
			settings.reticle_outer_width,
			settings.reticle_antialiased
		)
	if settings.reticle_separator_enabled:
		match settings.reticle_separator_type:
			RadialMenuSettings.SeparatorType.LINE:
				for i in items_radial_count:
					var point := Vector2.from_angle(i * sector_angle_full + start_angle_offset_radiants)
					draw_line(
						center + point * (dim_inner_radius + settings.reticle_inner_width/2.0),
						center + point * (settings.dim_outer_radius - settings.reticle_outer_width/2.0),
						settings.reticle_separator_color,
						settings.reticle_separator_width,
						settings.reticle_antialiased
					)
			RadialMenuSettings.SeparatorType.SECTOR:
				var res: int = int(settings.resolution/items_radial_count)
				for i in items_radial_count:
					var angle_center = i * sector_angle_full + start_angle_offset_radiants
					var poly: PackedVector2Array = get_sector_points(
						center,
						angle_center,
						sector_angle_gap,
						dim_inner_radius,
						settings.dim_outer_radius,
						res
					)
					draw_polygon(poly, [settings.reticle_separator_color])


func _draw_highlight() -> void:
	if selected_idx == -1:
		return
	if selected_idx == 0 and settings.first_item_centered:
		draw_circle(center, dim_inner_radius, settings.hover_color)
		return
	
	var idx: int = selected_idx if !settings.first_item_centered else selected_idx - 1
	var angle_center_selected: float = idx * sector_angle_full + sector_angle_full/2.0 + start_angle_offset_radiants
	var poly: PackedVector2Array = get_sector_points(
		center,
		angle_center_selected,
		sector_angle_net if settings.reticle_separator_type == RadialMenuSettings.SeparatorType.SECTOR else sector_angle_full,
		dim_inner_radius,
		settings.dim_outer_radius,
		sector_resolution
	)
	draw_polygon(poly, [settings.hover_color])


func _draw_icons() -> void:
	if settings.first_item_centered:
		var item: RadialMenuItem = items[0]
		var texture: Texture2D = item.image
		var color: Color = settings.hover_child_modulate if selected_idx == 0 else settings.item_modulate
		var factor := 1.0
		
		if settings.item_auto_size:
			factor = (settings.dim_outer_radius / (settings.item_size * 1.5)) * settings.item_auto_size_factor
		
		var rect := Rect2()
		rect.size = Vector2.ONE * settings.item_size
		rect.position = center - rect.size/2.0
		draw_texture_rect(texture, rect, false, color)
	
	for i: int in items_radial_count:
		var idx: int = i
		if settings.first_item_centered:
			idx = i + 1
		
		var item: RadialMenuItem = items[idx]
		var texture: Texture2D = item.image
		#var settings.item_size
		var color: Color = settings.hover_child_modulate if selected_idx == idx else settings.item_modulate
		var factor := 1.0
		
		if settings.item_auto_size:
			factor = (settings.dim_outer_radius / (settings.item_size * 1.5)) * settings.item_auto_size_factor
		
		var item_angle_pos: float = i * sector_angle_full + sector_angle_full / 2.0
		item_angle_pos += start_angle_offset_radiants
		var rect := Rect2()
		rect.size = Vector2.ONE * settings.item_size
		rect.position = Vector2.from_angle(item_angle_pos) * item_pos_radius
		rect.position += center - rect.size/2.0
		
		draw_texture_rect(texture, rect, false, color)


func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if !engine_preview: return
	# pointer position is the position of the mouse or controller action compared to the center
	var pointer_pos: Vector2 = get_local_mouse_position() - center
	var controller_vector: Vector2 = Input.get_vector(
		settings.move_left_action_name if !settings.move_left_action_name.is_empty() else &"ui_left",
		settings.move_right_action_name if !settings.move_right_action_name.is_empty() else &"ui_right",
		settings.move_back_action_name if !settings.move_back_action_name.is_empty() else &"ui_down",
		settings.move_forward_action_name if !settings.move_forward_action_name.is_empty() else &"ui_up",
		settings.controller_deadzone
	)
	var prev_selected_idx := selected_idx
	selected_idx = get_selection_at_position(pointer_pos)
	
	if selected_idx != prev_selected_idx:
		selection_changed.emit(selected_idx)
	
	update()
#endregion


#region Getters/Setters
func _get_auto_circle_radius() -> int:
	if size.x < size.y:
		return int(size.x / 2.0)
	return int(size.y / 2.0)


func _set_engine_preview(value: bool) -> void:
	engine_preview = value
	set_process(value)
#endregion


#region Utilities
func get_selection_at_position(_pointer_pos: Vector2) -> int:
	var angle: float = wrapf(_pointer_pos.angle() - start_angle_offset_radiants, 0.0, TAU)
	var _pointer_radius: float = _pointer_pos.length()
	var is_in_outer_circle: bool = _pointer_radius < settings.dim_outer_radius
	var is_in_inner_circle: bool = _pointer_radius < dim_inner_radius
	var is_in_doughnut: bool = is_in_outer_circle and not is_in_inner_circle
	
	if settings.first_item_centered and is_in_inner_circle:
		return 0
	
	if settings.keep_selection_outside or is_in_doughnut:
		var idx: int = floor((angle / TAU) * items_radial_count)
		if settings.first_item_centered:
			idx += 1
		return idx
	
	return -1


func select() -> void: # select currently hovered element
	if selected_idx == -1:
		selection_canceled.emit()
	else:
		slot_selected.emit(selected_idx)
		var item: RadialMenuItem = items[selected_idx]
		if item.callback:
			item.callback.call_deferred()
	
	selected_idx = -1


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

static func uv_from_sector_poly(_sector_poly_size: int) -> PackedVector2Array:
	var uv_poly := PackedVector2Array()
	var half_size: float = float(_sector_poly_size/2.0)
	var step: float = 1.0 / (half_size - 1.0)
	# inner points
	for i: int in half_size:
		var uv_p: Vector2 = Vector2(i * step, 0)
		uv_poly.append(uv_p)
	# outer points
	for i: int in half_size:
		var uv_p: Vector2 = Vector2((half_size -1 - i) * step, 1)
		uv_poly.append(uv_p)
	
	return uv_poly

#endregion


##region Conditional properties
#func _validate_property(property: Dictionary) -> void:
	#if property.name == "dim_outer_radius" and dim_autosize == true:
		#property.usage |= PROPERTY_USAGE_READ_ONLY
##endregion
