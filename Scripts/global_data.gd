extends Node

var current_map: Array[Array] = []

var current_health: int
var max_health: int
const STARTING_HEALTH: int = 130

var current_room: RoomData = null
var current_scene: Scenes
var floors_cleared: int

var custom_cursor_texture: Texture2D = preload("uid://mgdvfjvoj2br")
var custom_cursor_enabled: bool = true:
	set(value):
		custom_cursor_enabled = value
		if custom_cursor_enabled:
			Input.set_custom_mouse_cursor(custom_cursor_texture, Input.CURSOR_ARROW, Vector2.ZERO)
		else:
			Input.set_custom_mouse_cursor(null)
var screen_shake_enabled: bool = true

enum Scenes{
	TITLE,
	MAP,
	COMBAT,
	END_SCREEN,
	VICTORY_SCREEN
}

const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.TITLE: "uid://dxcd4ybx5h0e2",
	Scenes.MAP: "uid://kofi1tjdo4p7",
	Scenes.COMBAT: "uid://ck3klal7dhgl3",
	Scenes.END_SCREEN: "uid://bbw2md84mfdb",
	Scenes.VICTORY_SCREEN: "uid://1gyeumwpsqdd"
}

func _ready() -> void:
	custom_cursor_enabled = true
	reset_data.call_deferred()

func reset_data():
	current_room = null
	current_map.clear()
	max_health = STARTING_HEALTH
	current_health = max_health
	floors_cleared = 0
	DeckManager.reset_deck()

func room_cleared():
	if current_room == null:
		return
	
	floors_cleared += 1
	for curr_floor in current_map:
		for room: RoomData in curr_floor:
			if room == current_room:
				room.has_been_selected = true

var previous_enemy: CharacterData
