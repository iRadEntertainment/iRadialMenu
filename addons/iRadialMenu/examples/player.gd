extends CharacterBody3D

#@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D

var inputs_enabled: bool = true

func _input(event: InputEvent) -> void:
	if !inputs_enabled:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000 * $Camera3D.sensitivity


func _physics_process(_delta: float) -> void:
	move_char()


func move_char() -> void:
	if !inputs_enabled:
		return
	var direction = Vector3(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_E)) - float(Input.is_physical_key_pressed(KEY_Q)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	if Input.is_physical_key_pressed(KEY_SHIFT): # boost
		velocity = direction * 2.5 * 1.8
	else:
		velocity = direction * 2.5
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide()


#func check_interactibles() -> void:
	#if ray_cast_3d.is_colliding():
		#var collider: PhysicsBody3D = ray_cast_3d.get_collider()
		#if collider is Interactible:
			#interactible = collider
			#interactible.highlight(true)
			#return
	#if interactible:
		#interactible.highlight(false)
		#interactible = null


#func _on_interactible_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	#pass # Replace with function body.
