extends Node3D


var hovered_body: PhysicsBody3D
@onready var pin_joint_3d: PinJoint3D = $Player/Camera3D/PickerBody/PinJoint3D


@export_flags_3d_physics var interactible_collision_mask = 0xFFFFFFFF
var cam: Camera3D
var direct_space_state: PhysicsDirectSpaceState3D
var physic_query: PhysicsRayQueryParameters3D
var intersect_point: Vector3


func _ready() -> void:
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


func _process(_delta: float) -> void:
	check_hovered_interactibles()
	_debug_radial_menu()


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
	hovered_body = res.get("collider", null)
	var is_interactible: bool = false
	if hovered_body:
		is_interactible = hovered_body.has_node(^"Interactible")
		intersect_point = res.position
	$GUI/Reticle.crossair_type = 1 if is_interactible else 0


func _debug_radial_menu() -> void:
	var lb_style: StyleBoxFlat = $GUI/Info/lb_mouse_in_radial.get_theme_stylebox("normal")
	var intersection: Variant = $RadialMenuComponent._get_mouse_2D_pos_on_plane()
	lb_style.bg_color = Color.SEA_GREEN if intersection else Color.BROWN
	$GUI/Info/lb_mouse_in_radial.text = "%s" % intersection


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			if not pin_joint_3d.node_b.is_empty():
				pin_joint_3d.node_b = ""
		if event.is_pressed() \
				and event.button_index == MOUSE_BUTTON_MIDDLE \
				and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			var m_pos: Vector2 = get_viewport().get_mouse_position()
			var world_pos: Vector3 = screen_to_world_pos(m_pos, 100, cam)
			for i in randi_range(4, 8):
				add_banana_to_world(world_pos)


func add_banana_to_world(_world_pos: Vector3) -> void:
	var new_banananana: RigidBody3D= $Decorations/Banana.duplicate(0)
	new_banananana.position = _world_pos
	$Decorations.add_child(new_banananana)


func _on_interactible_just_left_clicked(body: PhysicsBody3D) -> void:
	print(body.name, " left clicked")
	$Player/Camera3D/PickerBody.global_position = intersect_point
	pin_joint_3d.node_b = pin_joint_3d.get_path_to(hovered_body)
	
func _on_interactible_just_right_clicked(body: PhysicsBody3D) -> void:
	$RadialMenuComponent.popup(body.global_position)
func _on_interactible_just_hovered(body: PhysicsBody3D) -> void:
	hovered_body = body



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
