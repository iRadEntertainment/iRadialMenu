extends Interactible


var is_open: bool = false
var tw: Tween

func _ready() -> void:
	super()
	var item_open := RadialMenuItem.new()
	item_open.texture = load("res://addons/iRadialMenu/examples/assets/Icons/door-handle.svg")
	item_open.name = "Open/Close"
	item_open.description = "Swing, swing!"
	item_open.callback = open_close_door
	var item_exit := RadialMenuItem.new()
	item_exit.texture = load("res://addons/iRadialMenu/examples/assets/Icons/exit_door.svg")
	item_exit.name = "Exit"
	item_exit.description = "Enough of this demo!"
	item_exit.callback = quit_game
	
	radial_items.append(item_open)
	radial_items.append(item_exit)


func open_close_door() -> void:
	is_open = !is_open
	if tw:
		tw.kill()
	
	var final_rotation: float = 0 if !is_open else -PI * 5/8
	
	tw = create_tween()
	tw.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(parent, ^"rotation:y", final_rotation, 0.85)


func quit_game() -> void:
	get_tree().quit()
