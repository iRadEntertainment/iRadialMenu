extends TextureRect

enum CrossairType {EMPTY, INTERACT}
const CROSSAIR_ICONS = [
	preload("res://addons/iRadialMenu/examples/assets/icon_crossair.png"),
	preload("res://addons/iRadialMenu/examples/assets/icon_interact.png"),
]


var crossair_type: CrossairType = CrossairType.EMPTY:
	set(val):
		if crossair_type == val:
			return
		crossair_type = val
		texture = CROSSAIR_ICONS[int(crossair_type)]
