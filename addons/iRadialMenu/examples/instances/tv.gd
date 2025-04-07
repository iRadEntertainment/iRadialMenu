extends StaticBody3D


@onready var television_vintage_clone_: MeshInstance3D = $"televisionVintage(Clone)"
@onready var sub_viewport: SubViewport = $"televisionVintage(Clone)/SubViewport"


var screen_material: StandardMaterial3D:
	get():
		return television_vintage_clone_.mesh.surface_get_material(4)

var emission_texture: ViewportTexture:
	get():
		return screen_material.emission_texture


func _ready() -> void:
	#emission_texture.viewport_path = television_vintage_clone_.get_path_to(sub_viewport)
	print(emission_texture.viewport_path)
