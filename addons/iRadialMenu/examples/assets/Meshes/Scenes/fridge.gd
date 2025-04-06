extends Interactible

enum FoodType{BANANA, EGG, EGGPLANT}

const foods = [
	preload("res://addons/iRadialMenu/examples/instances/banana.tscn"),
	preload("res://addons/iRadialMenu/examples/instances/egg.tscn"),
	preload("res://addons/iRadialMenu/examples/instances/eggplant.tscn"),
]

func _ready() -> void:
	super()


func spawn_food(_type: FoodType) -> void:
	var food: RigidBody3D = foods[_type].instantiate()
	
	%spawn_position.global_position
	parent.add_child(food)
