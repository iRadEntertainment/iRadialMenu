extends Node3D

var cam: Camera3D:
	get(): return get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	#Transform3D().looking_at(cam.global_position, Vector3.UP, true)
	$ProjectionPlane.global_transform = $ProjectionPlane.global_transform.looking_at(cam.global_position, Vector3.UP, true)
