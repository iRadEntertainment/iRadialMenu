@tool
class_name RadialMenuItem extends Resource

## Item item name as [String]
@export var name: String = ""
## Item item name as [String]
@export var description: String = ""
@export var texture: Texture2D
@export var callback_name: String = ""
var callback: Callable
var format_dictionary: Dictionary
