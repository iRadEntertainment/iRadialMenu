@icon("icon_radial_3d_2d.svg")
class_name RadialMenu3DFlat extends Node3D

# node references
var _cam: Camera3D:
	get(): return get_viewport().get_camera_3d()
var _plane_material: StandardMaterial3D:
	get(): return _plane.get_surface_override_material(0)
@onready var _plane: MeshInstance3D = $ProjectionPlane
@onready var mesh: PlaneMesh = $ProjectionPlane.mesh
@onready var sub_viewport: SubViewport = $ProjectionPlane/SubViewport
@onready var menu: RadialMenu2D = $ProjectionPlane/SubViewport/RadialMenu2D


## This will set the mouse mode on popup()
@export var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
## The resolution of the [SubViewport] in pixels used for rendering the 2D UI
@export var ui_resoulution: int = 512
## The dimension in world units of the [PlaneMesh] used for projecting the 2D interface
@export var ui_dimension: float = 0.4
## If [code]true[/code] will place the menu at [code]distance_from_camera[/code] from the current world [Camera]
@export var fix_distance: bool = true
## The distance from the current [Camera] in 3D world units
@export var distance_from_camera: float = 1.0
## If [code]true[/code] it will ignore the depth test for rendering the Menu
@export var draw_on_top: bool = true
## If [code]true[/code] blocks the signals to propagate behind the Menu
@export var prevent_propagate: bool = true
## If [code]true[/code] will tilt the Plane following the mouse position
@export var tilt_with_mouse: bool = true
## The strength of the tilt in radiants, if [code]tilt_wit_mouse[/code] is [code]true[/code]
@export_range(0.0, 2.0, 0.01) var tilt_strength: float = 0.2


var previous_mouse_mode: Input.MouseMode
var tw: Tween

signal option_selected(selected: int, control_node: Control)


#region Init
func _ready() -> void:
	hide()
	_connect_signals()
	
	_plane_material.no_depth_test = draw_on_top


func _connect_signals() -> void:
	menu.slot_selected.connect(_on_slot_selected)
	visibility_changed.connect(_on_visibility_changed)
#endregion


#region Main functions
func popup(_pop_global_position: Vector3) -> void:
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = mouse_mode
	
	global_position = _pop_global_position
	if fix_distance:
		var dist: Vector3 = _pop_global_position - _cam.global_position
		if pow(distance_from_camera, 2) < dist.length_squared():
			var dir: Vector3 = _cam.global_position.direction_to(_pop_global_position)
			var fixed_distance_position: Vector3 = _cam.global_position + dir * distance_from_camera
			
			global_position = fixed_distance_position
	
	_face_camera()
	show()
	_plane.scale = Vector3.ZERO
	
	if tw: tw.kill()
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(_plane, ^"scale", Vector3.ONE, 0.3)


func close_popup() -> void:
	Input.mouse_mode = previous_mouse_mode
	
	if tw: tw.kill()
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(_plane, ^"scale", Vector3.ZERO, 0.3)
	tw.tween_callback(hide)
#endregion


#region Update
func _set_properties() -> void:
	pass


func _face_camera() -> void:
	_plane.global_rotation = _cam.global_rotation
	
	if !tilt_with_mouse: return
	
	# tilt _plane with mouse
	var m_pos: Vector2 = get_viewport().get_mouse_position()
	var tilt: Vector2 = m_pos - Vector2(get_viewport().size)/2.0
	tilt /= Vector2(sub_viewport.size)
	tilt *= tilt_strength
	
	_plane.global_rotation = _cam.global_rotation + Vector3(-tilt.y, -tilt.x, 0)


func _input(event: InputEvent) -> void:
	if not visible: return
	_face_camera()
	if tw:
		if tw.is_running():
			return
	
	if event is InputEventMouse:
		# check for events on _plane
		var m_pos: Variant = _get_mouse_2D_pos_on_plane()
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
#endregion


#region Utilities
func _get_mouse_2D_pos_on_plane() -> Variant:
	var proj: Variant = _get_mouse_on_projection_plane()
	if proj:
		var mouse_pos := Vector2(proj.x, proj.y)
		mouse_pos += mesh.size * 0.5
		mouse_pos /= mesh.size
		mouse_pos.y = 1.0 - mouse_pos.y
		mouse_pos *= Vector2(sub_viewport.size)
		return Vector2i(mouse_pos)
	
	return null


func _get_mouse_on_projection_plane() -> Variant:
	if _plane.scale == Vector3.ZERO:
		return
	var from: Vector3
	var dir: Vector3
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		from = _cam.global_position
		dir = -_cam.global_transform.basis.z
	else:
		var screen_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		from = _cam.project_ray_origin(screen_mouse_pos)
		dir = _cam.project_ray_normal(screen_mouse_pos)
	
	# get the _plane mesh points
	var array_mesh: Array = mesh.get_mesh_arrays()
	var triangle_1: PackedVector3Array = array_mesh[0]
	var a: Vector3 = triangle_1[0]
	var b: Vector3 = triangle_1[1]
	var c: Vector3 = triangle_1[2]
	var d: Vector3 = Vector3(b.x, c.y, b.z)
	
	# apply the inverse of the global transform of the _plane
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
		_face_camera()


func _on_slot_selected(control_node: Control, index: int) -> void:
	option_selected.emit(control_node, index)
	close_popup()
#endregion
