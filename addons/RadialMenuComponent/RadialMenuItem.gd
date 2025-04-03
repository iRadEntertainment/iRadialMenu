@tool
class_name RadialMenuItem extends Resource

@export var option_name: String = ""
@export var description: String = ""
@export var image: Texture2D
@export var callback_name: String = ""
var callback: Callable
var format_dictionary: Dictionary
