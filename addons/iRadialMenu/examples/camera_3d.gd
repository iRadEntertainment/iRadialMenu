extends Camera3D

@export_range(0, 10, 0.01) var sensitivity : float = 3

var tw: Tween
@onready var cam_height_default: float = position.y

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
		if event.is_echo():
			return
		if event.keycode == KEY_Q and event.is_pressed():
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.keycode == KEY_CTRL:
			var target_height: float
			if event.is_pressed():
				target_height = cam_height_default - 0.95
			else:
				target_height = cam_height_default
				
			if tw:
				tw.kill()
			
			tw = create_tween()
			tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
			tw.tween_property(self, ^"position:y", target_height, 0.35)
