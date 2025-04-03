@tool
@icon("icon_radial_3d_2d.svg")
class_name RadialMenu3DFlat extends Node3D


@export var engine_preview: bool = true: set = _set_engine_preview
@export var reset_nodes: bool = false:
	set(val):
		reset_nodes = val
		if is_node_ready():
			create_nodes()
			setup_nodes()
@export var items: Array[RadialMenuItem]
@export var settings2D := RadialMenuSettings.new():
	set(val):
		settings2D = val
		if not is_node_ready():
			await ready
		radial_menu_2d.settings = settings2D


@export_group("Settings")
## This will set the mouse mode on popup()
@export var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
## The resolution of the [SubViewport] in pixels used for rendering the 2D UI
@export var ui_resolution: int = 512
## The dimension in world units of the [PlaneMesh] used for projecting the 2D interface
@export var ui_dimension: float = 0.4
## If [code]true[/code] will place the radial_menu_2d at [code]distance_from_camera[/code] from the current world [Camera]
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

#region Node references
var _cam: Camera3D:
	get():
		if Engine.is_editor_hint():
			return EditorInterface.get_editor_viewport_3d().get_camera_3d()
		return get_viewport().get_camera_3d()

var _plane: MeshInstance3D
var _plane_material: StandardMaterial3D:
	get():
		return _plane.get_surface_override_material(0)
var _mesh: PlaneMesh
var sub_viewport: SubViewport
var radial_menu_2d: RadialMenu2D
#endregion

#region Functional variables
var previous_mouse_mode: Input.MouseMode
var tw: Tween
#endregion

signal option_selected(selected: int)


#region Init
func _ready() -> void:
	create_nodes()
	setup_nodes()
	_connect_signals()
	
	if not Engine.is_editor_hint():
		hide()


func create_nodes() -> void:
	for child in get_children(true):
		child.queue_free()
	
	_plane = MeshInstance3D.new()
	_plane.name = "Plane"
	_mesh = PlaneMesh.new()
	_mesh.orientation = PlaneMesh.FACE_Z
	_plane.mesh = _mesh
	_plane.set_surface_override_material(0, load("res://addons/RadialMenuComponent/RadialMenuPlane.material").duplicate())
	
	sub_viewport = SubViewport.new()
	sub_viewport.name = "SubViewport"
	sub_viewport.transparent_bg = true
	radial_menu_2d = RadialMenu2D.new()
	radial_menu_2d.name = "RadialMenu2D"
	
	sub_viewport.add_child(radial_menu_2d)
	_plane.add_child(sub_viewport)
	add_child(_plane)
	#_plane_material.albedo_texture = sub_viewport.get_texture()


func setup_nodes() -> void:
	_mesh.size = ui_dimension * Vector2.ONE
	_plane_material.no_depth_test = draw_on_top
	sub_viewport.size = ui_resolution * Vector2i.ONE
	_plane_material.albedo_texture.viewport_path = get_path_to(sub_viewport)
	radial_menu_2d.position = Vector2.ZERO
	radial_menu_2d.size = sub_viewport.size
	radial_menu_2d.set_anchors_preset(Control.PRESET_FULL_RECT)
	radial_menu_2d.items = items


func _connect_signals() -> void:
	radial_menu_2d.slot_selected.connect(_on_slot_selected)
	visibility_changed.connect(_on_visibility_changed)
#endregion


#region Update
func _process(delta: float) -> void:
	if not Engine.is_editor_hint() or not engine_preview:
		return
	
	_face_camera()
	var m_pos: Variant = _get_mouse_2D_pos_on_plane()
	if not m_pos:
		return
	
	# push the event to the subviewport converted to 2D space
	var event_2d := InputEventMouseMotion.new()
	event_2d.position = m_pos
	sub_viewport.push_input(event_2d)
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
		mouse_pos += _mesh.size * 0.5
		mouse_pos /= _mesh.size
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
	var array_mesh: Array = _mesh.get_mesh_arrays()
	var triangle_1: PackedVector3Array = array_mesh[0]
	var a: Vector3 = triangle_1[0]
	var b: Vector3 = triangle_1[1]
	var c: Vector3 = triangle_1[2]
	var d: Vector3 = Vector3(b.x, c.y, b.z)
	
	# apply the inverse of the global transform of the _plane
	var inv_global_trans: Transform3D = _plane.global_transform.affine_inverse()
	a *= inv_global_trans
	b *= inv_global_trans
	c *= inv_global_trans
	d *= inv_global_trans
	
	# check for intersection with the two triangles
	var itersect_bot_triangle: Variant = Geometry3D.ray_intersects_triangle(from, dir, a, b, c)
	var itersect_top_triangle: Variant = Geometry3D.ray_intersects_triangle(from, dir, b, c, d)
	
	if itersect_bot_triangle:
		return itersect_bot_triangle * _plane.global_transform
	if itersect_top_triangle:
		return itersect_top_triangle * _plane.global_transform
	return null
#endregion


#region Setters
func _set_engine_preview(value: bool) -> void:
	engine_preview = value
	set_process(engine_preview)
	if radial_menu_2d:
		radial_menu_2d.engine_preview = engine_preview
#endregion


#region Signals
func _on_visibility_changed() -> void:
	if visible:
		_face_camera()


func _on_slot_selected(index: int) -> void:
	option_selected.emit(index)
	close_popup()
#endregion
