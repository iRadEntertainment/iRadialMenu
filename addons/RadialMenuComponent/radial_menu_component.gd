extends Node3D


var cam: Camera3D:
	get(): return get_viewport().get_camera_3d()
@onready var plane: MeshInstance3D = $ProjectionPlane
@onready var mesh: PlaneMesh = $ProjectionPlane.mesh
@onready var sub_viewport: SubViewport = $ProjectionPlane/SubViewport
@onready var menu: RadialMenuAdvanced = $ProjectionPlane/SubViewport/RadialMenuAdvanced

var plane_material: StandardMaterial3D:
	get(): return plane.get_surface_override_material(0)

@export var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
@export var fix_distance: bool = true
@export var distance_from_camera: float = 1.0
@export var draw_on_top: bool = true
@export var prevent_propagate: bool = true


var previous_mouse_mode: Input.MouseMode
var tw: Tween

signal option_selected(selected: int, control_node: Control)


func _ready() -> void:
	hide()
	
	plane_material.no_depth_test = draw_on_top
	
	menu.slot_selected.connect(_on_slot_selected)
	visibility_changed.connect(_on_visibility_changed)


func popup(_pop_global_position: Vector3) -> void:
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = mouse_mode
	
	global_position = _pop_global_position
	if fix_distance:
		var dist: Vector3 = _pop_global_position - cam.global_position
		if pow(distance_from_camera, 2) < dist.length_squared():
			var dir: Vector3 = cam.global_position.direction_to(_pop_global_position)
			var fixed_distance_position: Vector3 = cam.global_position + dir * distance_from_camera
			
			global_position = fixed_distance_position
	
	face_camera()
	show()
	plane.scale = Vector3.ZERO
	
	if tw: tw.kill()
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(plane, ^"scale", Vector3.ONE, 0.3)


func close_popup() -> void:
	Input.mouse_mode = previous_mouse_mode
	
	if tw: tw.kill()
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(plane, ^"scale", Vector3.ZERO, 0.3)
	tw.tween_callback(hide)


func face_camera() -> void:
	plane.global_rotation = cam.global_rotation


func _input(event: InputEvent) -> void:
	if not visible: return
	face_camera()
	if tw:
		if tw.is_running():
			return
	
	if event is InputEventMouse:
		# check for events on plane
		var m_pos: Variant = get_mouse_2D_pos_on_plane()
		if not m_pos:
			if event is InputEventMouseButton:
				close_popup()
			return
		
		# set event as handled
		if prevent_propagate:
			get_viewport().set_input_as_handled()
		
		# push the event to the subviewport converted to 2D space
		var event_2d := event.duplicate(true)
		event_2d.position = m_pos
		sub_viewport.push_input(event_2d)


#region Utilities
func get_mouse_2D_pos_on_plane() -> Variant:
	var proj: Variant = get_mouse_on_projection_plane()
	if proj:
		var mouse_pos := Vector2(proj.x, proj.y)
		mouse_pos += mesh.size * 0.5
		mouse_pos /= mesh.size
		mouse_pos.y = 1.0 - mouse_pos.y
		mouse_pos *= Vector2(sub_viewport.size)
		return Vector2i(mouse_pos)
	
	return null


func get_mouse_on_projection_plane() -> Variant:
	if plane.scale == Vector3.ZERO:
		return
	var from: Vector3
	var dir: Vector3
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		from = cam.global_position
		dir = -cam.global_transform.basis.z
	else:
		var screen_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		from = cam.project_ray_origin(screen_mouse_pos)
		dir = cam.project_ray_normal(screen_mouse_pos)
	
	# get the plane mesh points
	var array_mesh: Array = mesh.get_mesh_arrays()
	var triangle_1: PackedVector3Array = array_mesh[0]
	var a: Vector3 = triangle_1[0]
	var b: Vector3 = triangle_1[1]
	var c: Vector3 = triangle_1[2]
	var d: Vector3 = Vector3(b.x, c.y, b.z)
	
	# apply the inverse of the global transform of the plane
	var inv_global_trans: Transform3D = $ProjectionPlane.global_transform.affine_inverse()
	a *= inv_global_trans
	b *= inv_global_trans
	c *= inv_global_trans
	d *= inv_global_trans
	
	# check for intersection with the two triangles
	var itersect_bot_triangle: Variant = Geometry3D.ray_intersects_triangle(from, dir, a, b, c)
	var itersect_top_triangle: Variant = Geometry3D.ray_intersects_triangle(from, dir, b, c, d)
	
	if itersect_bot_triangle:
		return itersect_bot_triangle * $ProjectionPlane.global_transform
	if itersect_top_triangle:
		return itersect_top_triangle * $ProjectionPlane.global_transform
	return null
#endregion


#region Signals
func _on_visibility_changed() -> void:
	if visible:
		face_camera()


func _on_slot_selected(control_node: Control, index: int) -> void:
	option_selected.emit(control_node, index)
	close_popup()
#endregion
