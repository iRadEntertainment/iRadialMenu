extends Control

var current_mpos: Vector2

func _process(delta: float) -> void:
	queue_redraw()


func input_from_3D_world(event: InputEventMouse) -> void:
	current_mpos = event.position


#func _draw() -> void:
	#draw_circle(current_mpos, 8, Color.RED)
