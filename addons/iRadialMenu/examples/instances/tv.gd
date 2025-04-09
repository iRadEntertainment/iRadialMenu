extends StaticBody3D


@onready var television_vintage_clone_: MeshInstance3D = $"televisionVintage(Clone)"
@onready var sub_viewport: SubViewport = $"televisionVintage(Clone)/SubViewport"

var radial_menu: RadialMenu3DFlat:
	get():
		return get_tree().current_scene.radial_menu

var streamers_dict = {
	"Fin": {"description": "is fine",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/finisfine.png"),
			"twitch_link": "https://www.twitch.tv/finisfine"
	},
	"Wardstone": {"description": "Cool shirts",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/wardstonestudio.png"),
			"twitch_link": "https://www.twitch.tv/foolbox"
	},
	"HypnotiK": {"description": "The amazingness",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/hypnotik.png"),
			"twitch_link": "https://www.twitch.tv/hypnotik_games"
	},
	"JustCovino": {"description": "Just FFS",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/justcovino.png"),
			"twitch_link": "https://www.twitch.tv/justcovino"
	},
	"Earend": {"description": "A bear it's a bear it's a bear",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/earend.png"),
			"twitch_link": "https://www.twitch.tv/earend"
	},
	"Seano4D": {"description": "Balls",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/seano4d.png"),
			"twitch_link": "https://www.twitch.tv/seano4d",
			"trailer": "res://addons/iRadialMenu/examples/assets/videos/seano4d_clip.ogv"
	},
	"AnihanShard": {"description": "Happy birthday",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/anihanshard.png"),
			"twitch_link": "https://www.twitch.tv/anihanshard"
	},
	"FoolBox": {"description": "furuba",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/fullbocksoo.png"),
			"twitch_link": "https://www.twitch.tv/foolbox",
			"trailer": "res://addons/iRadialMenu/examples/assets/videos/Block-Shop_Trailer3.ogv"
	},
	"IrishJohn": {"description": "Elbows",
			"texture": preload("res://addons/iRadialMenu/examples/assets/FeaturedStreamers/irishjohn.png"),
			"twitch_link": "https://www.twitch.tv/irishjohngames"
	},
	"PracticalNPC": {"description": "W",
			"texture": preload("res://addons/iRadialMenu/examples/assets/Icons/tv.svg"),
			"twitch_link": "https://www.twitch.tv/practicalnpc",
			"trailer": "res://addons/iRadialMenu/examples/assets/videos/30_second_memori_trailer.ogv"
	}
}


var streamers_items: Array[RadialMenuItem]

var screen_material: StandardMaterial3D:
	get():
		return television_vintage_clone_.mesh.surface_get_material(4)

var emission_texture: ViewportTexture:
	get():
		return screen_material.emission_texture


func _ready() -> void:
	_setup_streamer_items()


func _setup_streamer_items() -> void:
	for item_name: String in streamers_dict:
		var item := RadialMenuItem.new()
		item.name = item_name
		item.description = streamers_dict[item_name].get("description", "")
		item.texture = streamers_dict[item_name].get("texture")
		item.callback = _on_streamer_pressed.bind(item_name)
		streamers_items.append(item)
	
	$Interactible.radial_items = streamers_items


func _on_streamer_pressed(streamer_name: String) -> void:
	radial_menu.items = get_streamer_sub_menu(streamer_name)
	radial_menu.popup_screen_center()


func get_streamer_sub_menu(streamer_name: String) -> Array[RadialMenuItem]:
	var twitch_link: String = streamers_dict[streamer_name].get("twitch_link", "")
	var trailer: String = streamers_dict[streamer_name].get("trailer", "")
	
	var new_items: Array[RadialMenuItem] = []
	
	var item_open_twitch := RadialMenuItem.new()
	item_open_twitch.name = "Watch %s!" % streamer_name
	item_open_twitch.description = "Open %s Twitch page" % streamer_name
	item_open_twitch.texture = load("res://addons/iRadialMenu/examples/assets/Icons/tv.svg")
	item_open_twitch.callback = open_twitch_page.bind(twitch_link)
	new_items.append(item_open_twitch)
	
	if !trailer.is_empty():
		var item_play_clip := RadialMenuItem.new()
		item_play_clip.name = "Swap channel"
		item_play_clip.description = "Something interesting from %s" % streamer_name
		item_play_clip.texture = load("res://addons/iRadialMenu/examples/assets/Icons/tv-remote.svg")
		item_play_clip.callback = play_clip.bind(trailer)
		new_items.append(item_play_clip)
	
	var item_go_back := RadialMenuItem.new()
	item_go_back.name = "Back"
	item_go_back.description = ""
	item_go_back.texture = load("res://addons/iRadialMenu/examples/assets/Icons/boomerang.svg")
	item_go_back.callback = go_to_main_tv_menu
	new_items.append(item_go_back)
	
	return new_items


func go_to_main_tv_menu() -> void:
	radial_menu.items = streamers_items
	radial_menu.popup_screen_center()


func play_clip(clip_path: String) -> void:
	%VideoStreamPlayer.stop()
	%VideoStreamPlayer.stream = load(clip_path)
	%VideoStreamPlayer.play()


func open_twitch_page(twitch_link: String) -> void:
	OS.shell_open(twitch_link)
