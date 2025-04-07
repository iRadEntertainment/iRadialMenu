@tool
## A resource that represents a single item in a radial menu.
##
## [RadialMenuItem] stores the visual and functional properties of a menu option
## displayed in the [RadialMenu2D] control. Each item can have a name, description,
## texture, and callback functionality when selected.
class_name RadialMenuItem extends Resource

## The display name of the menu item.
## This text is shown in the center preview when the item is hovered over and
## is passed as a parameter in the [signal RadialMenu2D.selected] signal.
@export var name: String = ""

## A detailed description of the menu item.
## This text is displayed in the center preview when the item is hovered over,
## typically shown below the item name to provide additional context.
@export var description: String = ""

## The icon or image representing this menu item in the radial menu.
## This texture is displayed in the menu sector for this item and in the center preview
## when the item is hovered over. For best results, use transparent images.
@export var texture: Texture2D

## The name of a method to call when this item is selected.
## If specified, the RadialMenu2D will attempt to call a method with this name
## on itself when the item is selected. The method should be defined in a script
## that extends RadialMenu2D.
@export var callback_name: String = ""

## A direct callable reference to execute when this item is selected.
## This provides an alternative to [member callback_name] when you want to
## connect the item to a function dynamically at runtime.
var callback: Callable

## A dictionary for formatting the name and description strings.
## When set, the menu item will use [method String.format] with this dictionary
## to process the name and description, allowing for dynamic text content.
var format_dictionary: Dictionary
