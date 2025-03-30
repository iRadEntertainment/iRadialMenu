extends Node3D
class_name Interactible

@export_flags_3d_physics var collision_mask = 0xFFFFFFFF

var parent: PhysicsBody3D
var mesh_instance: MeshInstance3D
var next_pass_material: ShaderMaterial

var direct_space_state: PhysicsDirectSpaceState3D
var physic_query: PhysicsRayQueryParameters3D
var cam: Camera3D

var is_hovered := false:
	set(val):
		if is_hovered == val:
			return
		is_hovered = val
		highlight(is_hovered)

signal just_hovered(body: PhysicsBody3D)
signal just_left_clicked(body: PhysicsBody3D)
signal just_right_clicked(body: PhysicsBody3D)



func _ready() -> void:
	# Guard statements
	if not get_parent() is PhysicsBody3D:
		printerr("Interactible: assigned to a node that doesn't extends PhysicsBody3D")
		queue_free()
		return
	
	# setup the query parameters fro raycasting in direct space
	physic_query = PhysicsRayQueryParameters3D.new()
	physic_query.collide_with_bodies = true
	physic_query.collision_mask = collision_mask
	
	# fetch references
	cam = get_viewport().get_camera_3d()
	direct_space_state = get_world_3d().direct_space_state
	parent = get_parent()
	mesh_instance = find_first_mesh_in_node_3D(parent)
	if !mesh_instance:
		printerr("Interactible: cannot find a mesh in the parent object")
		queue_free()
		return
	
	## connect signals
	#mouse_entered.connect(highlight.bind(true))
	#mouse_exited.connect(highlight.bind(false))
	
	add_to_group("interactibles")
	
	# load and apply next pass material for the highlight
	next_pass_material = load("res://addons/RadialMenuComponent/examples/assets/outline_next_pass.tres").duplicate()
	mesh_instance.mesh.surface_get_material(0).next_pass = next_pass_material
	next_pass_material.set_shader_parameter("outline_color", Color.TRANSPARENT)


func _input(event: InputEvent) -> void:
	if !is_hovered:
		return
	if event is InputEventMouseButton:
		if event.is_released(): return
		if event.button_index == MOUSE_BUTTON_LEFT:
			just_left_clicked.emit(parent)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			just_right_clicked.emit(parent)


func _physics_process(_delta: float) -> void:
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
	var found: PhysicsBody3D = res.get("collider", null)
	is_hovered = found == parent


func highlight(toggle: bool) -> void:
	if not mesh_instance: return
	next_pass_material.set_shader_parameter("outline_color", Color.RED if toggle else Color.TRANSPARENT)


static func find_first_mesh_in_node_3D(node: Node3D, exclude: Array = []) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			if !child in exclude:
				return child
		if child.get_child_count() != 0:
			var found = find_first_mesh_in_node_3D(child, exclude)
			if found:
				return found
	return null


static func get_children_recursive(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child in node.get_children():
		found.append(child)
		if child.get_child_count() != 0:
			found.append_array(get_children_recursive(child))
	return found
