extends StaticBody3D


@onready var television_vintage_clone_: MeshInstance3D = $"televisionVintage(Clone)"
@onready var sub_viewport: SubViewport = $"televisionVintage(Clone)/SubViewport"

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
			"twitch_link": "https://www.twitch.tv/foolbox"
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
	var description: String = streamers_dict[streamer_name].get("description", "")
	var texture: Texture2D = streamers_dict[streamer_name].get("texture", null)
	var twitch_link: String = streamers_dict[streamer_name].get("twitch_link", "")
	var trailer: String = streamers_dict[streamer_name].get("trailer", "")
	print("Streamer clicked: ", streamer_name)
	if !trailer.is_empty():
		print("trailer: ", trailer)
		%VideoStreamPlayer.stop()
		%VideoStreamPlayer.stream = load(trailer)
		%VideoStreamPlayer.play()
