extends Node3D


var hovered_body: PhysicsBody3D
var picked_body: PhysicsBody3D

var main_radial_menu_items: Array[RadialMenuItem]
@export_flags_3d_physics var interactible_collision_mask = 0xFFFFFFFF
var cam: Camera3D
var direct_space_state: PhysicsDirectSpaceState3D
var physic_query: PhysicsRayQueryParameters3D
var intersect_point: Vector3

@onready var radial_menu: RadialMenu3DFlat = %RadialMenu3DFlat


func _ready() -> void:
	main_radial_menu_items = radial_menu.items
	cam = get_viewport().get_camera_3d()
	direct_space_state = get_world_3d().direct_space_state
	physic_query = PhysicsRayQueryParameters3D.new()
	physic_query.collide_with_bodies = true
	physic_query.collision_mask = interactible_collision_mask
	# connect all interactibles signals
	for interactible: Interactible in get_tree().get_nodes_in_group("interactibles"):
		interactible.just_left_clicked.connect(_on_interactible_just_left_clicked)
		interactible.just_right_clicked.connect(_on_interactible_just_right_clicked)
		interactible.just_hovered.connect(_on_interactible_just_hovered)
	
	radial_menu.visibility_changed.connect(_on_radial_menu_visibility_changed)


func _process(_delta: float) -> void:
	_debug_radial_menu()


func _physics_process(delta: float) -> void:
	check_hovered_interactibles()


func check_hovered_interactibles() -> void:
	if !cam:
		return
	
	var _from: Vector3
	var _to: Vector3
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_from = cam.global_position
		_to = _from - cam.global_transform.basis.z * 2.0 # meters
	else:
		var screen_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		_from = cam.project_ray_origin(screen_mouse_pos)
		_to = _from + cam.project_ray_normal(screen_mouse_pos) * 100
	
	physic_query.from = _from
	physic_query.to = _to
	
	var res: Dictionary = direct_space_state.intersect_ray(physic_query)
	var collider: Node3D = res.get("collider", null)
	var is_interactible: bool = false
	if collider:
		is_interactible = collider.has_node(^"Interactible")
		hovered_body = collider if is_interactible else null
		if is_interactible:
			intersect_point = res.position
	else:
		hovered_body = null
	
	$GUI/Reticle.crossair_type = 1 if is_interactible else 0


func _debug_radial_menu() -> void:
	var lb_style: StyleBoxFlat = %lb_mouse_in_radial.get_theme_stylebox("normal")
	var intersection: Variant = radial_menu._get_mouse_2D_pos_on_plane()
	lb_style.bg_color = Color.SEA_GREEN if intersection else Color.BROWN
	%lb_mouse_in_radial.text = "%s" % intersection
	%lb_hovered.text = "Hovered: %s" % [hovered_body]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			if not %PinJoint3D1.node_b.is_empty():
				%PinJoint3D1.node_b = ""
		if event.is_pressed() \
				and event.button_index == MOUSE_BUTTON_MIDDLE \
				and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			var m_pos: Vector2 = get_viewport().get_mouse_position()
			var world_pos: Vector3 = screen_to_world_pos(m_pos, 100, cam)
			for i in randi_range(4, 8):
				add_banana_to_world(world_pos)
		if event.is_released() and event.button_index == MOUSE_BUTTON_RIGHT:
			if radial_menu.visible:
				return
			if hovered_body:
				var interactible: Interactible = hovered_body.get_node(^"Interactible")
				radial_menu.items = interactible.radial_items
				radial_menu.popup_screen_center()
			


func add_banana_to_world(_world_pos: Vector3) -> void:
	var new_banananana: RigidBody3D = preload("res://addons/iRadialMenu/examples/instances/banana.tscn").instantiate()
	new_banananana.position = _world_pos
	new_banananana.rotate_y(randf_range(0, TAU))
	%Interactibles.add_child(new_banananana)


func _on_interactible_just_left_clicked(interactible: Interactible, body: PhysicsBody3D) -> void:
	if not hovered_body:
		return
	
	# pick rigid bodies
	if body is RigidBody3D:
		%PickerBody.global_position = intersect_point
		%PinJoint3D1.node_b = %PinJoint3D1.get_path_to(hovered_body)
		picked_body = hovered_body


func _on_interactible_just_right_clicked(interactible: Interactible, body: PhysicsBody3D) -> void:
	pass
	#if radial_menu.visible: return
	#radial_menu.items = interactible.radial_items
	#radial_menu.popup_screen_center()


func _on_interactible_just_hovered(interactible: Interactible, body: PhysicsBody3D) -> void:
	pass
	#hovered_body = body


func _on_radial_menu_visibility_changed() -> void:
	%Reticle.visible = !radial_menu.visible
	$Player.inputs_enabled = !radial_menu.visible


static func screen_to_world_pos(screen_pos: Vector2, distance_m: float, cam: Camera3D) -> Variant:
	var screen_cast_param := PhysicsRayQueryParameters3D.new()
	screen_cast_param.from = cam.project_ray_origin(screen_pos)
	screen_cast_param.to = screen_cast_param.from
	screen_cast_param.to += cam.project_ray_normal(screen_pos) * distance_m
	var dir_space := cam.get_world_3d().direct_space_state as PhysicsDirectSpaceState3D
	var res: Dictionary = dir_space.intersect_ray(screen_cast_param)
	var found_pos: Vector3 = res.position # TODO if not intersecting
	if not res: return
	return found_pos
