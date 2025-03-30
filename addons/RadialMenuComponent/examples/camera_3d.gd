extends Camera3D

@export_range(0, 10, 0.01) var sensitivity : float = 3


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if not current:
		return
	# rotate camera up and down
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.x = clamp(rotation.x, PI/-2, PI/2)
	
	# change FOV
	if event is InputEventMouseButton:
		if event.is_released(): return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov = min(120.0, fov + 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov = max(25.0, fov - 2.0)
	
	# toggle capture
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo() and event.keycode == KEY_CTRL:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
