extends Interactible

enum FoodType{BANANA, EGG, EGGPLANT}

const foods = [
	preload("res://addons/iRadialMenu/examples/instances/banana.tscn"),
	preload("res://addons/iRadialMenu/examples/instances/egg.tscn"),
	preload("res://addons/iRadialMenu/examples/instances/eggplant.tscn"),
]

const food_dictionary: Dictionary = {
	"Banana":
		[
			"Grab a Banana",
			preload("res://addons/iRadialMenu/examples/assets/Icons/banana.svg"),
			FoodType.BANANA,
		],
	"Egg":
		[
			"Grab a Egg",
			preload("res://addons/iRadialMenu/examples/assets/Icons/big-egg.svg"),
			FoodType.EGG,
		],
	"Eggplant":
		[
			"Grab a Eggplant",
			preload("res://addons/iRadialMenu/examples/assets/Icons/aubergine.svg"),
			FoodType.EGGPLANT,
		],
}

func _ready() -> void:
	super()
	radial_items.clear()
	for item_name: String in food_dictionary:
		var description: String = food_dictionary[item_name][0]
		var texture: Texture2D = food_dictionary[item_name][1]
		var callable_binding: FoodType = food_dictionary[item_name][2]
		var new_item := RadialMenuItem.new()
		
		new_item.name = item_name
		new_item.description = description
		new_item.texture = texture
		new_item.callback = spawn_food.bind(callable_binding)
		
		radial_items.append(new_item)


func spawn_food(_type: FoodType) -> void:
	var food: RigidBody3D = foods[_type].instantiate()
	food.position = %spawn_position.position
	parent.add_child(food)
