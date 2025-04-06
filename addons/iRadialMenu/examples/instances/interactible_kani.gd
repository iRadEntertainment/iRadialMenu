extends Interactible

@onready var particles: GPUParticles3D = $"../Particles"


func _ready() -> void:
	super()
	
	var kani_stream: RadialMenuItem = radial_items[0]
	var love: RadialMenuItem = radial_items[1]
	var love_more: RadialMenuItem = radial_items[2]
	
	kani_stream.callback = _on_watch_kani
	love.callback = _on_love
	love_more.callback = _on_love_more


func _on_watch_kani() -> void:
	OS.shell_open("https://www.twitch.tv/kani_dev")
func _on_love() -> void:
	particles.amount = 50
	particles.emitting = true
func _on_love_more() -> void:
	particles.amount = 250
	particles.emitting = true
