class_name MapButton
extends Node2D

@export var room_data: RoomData
@export var icon: TextureRect = null
@export var button: BaseButton = null
@export var checkmark: Node2D = null
@export var pulse_speed: float = 4
@export var pulse_amount: float = 0.1

@export var room_icons: Dictionary[RoomData.Type, Texture2D] = {
	RoomData.Type.NOT_ASSIGNED: null,
	RoomData.Type.BOSS: null,
	RoomData.Type.COMBAT: null,
	RoomData.Type.REWARD: null,
	RoomData.Type.REST: null
}

@export var room_button_scale_ratios: Dictionary[RoomData.Type, float] = {
	RoomData.Type.NOT_ASSIGNED: 0.0,
	RoomData.Type.BOSS: 1.5,
	RoomData.Type.COMBAT: 1,
	RoomData.Type.REWARD: 1,
	RoomData.Type.REST: 1
}

var base_scale: Vector2

var map_generator: MapGenerator:
	get: return ManagerRegistry.get_manager("map_generator")

func button_setup(room: RoomData):
	if room == null:
		return
	room_data = room
	scale *= room_button_scale_ratios[room_data.type]
	position = room_data.position
	if icon:
		icon.texture = room_icons[room_data.type]
	set_button_available.call_deferred()
	
	if room_data.has_been_selected and checkmark != null:
		checkmark.show()


func set_button_available():
	if room_data.row == 0 and GlobalData.floors_cleared == 0:
		_disable_button(false)
		return
	
	#if room_data.type == RoomData.Type.BOSS:
	#	_disable_button(false)
	#	return
	
	#if room_data.type == RoomData.Type.REST:
	#	_disable_button(false)
	#	return
	
	#if room_data.type == RoomData.Type.REWARD:
	#	_disable_button(false)
	#	return
	
	if _is_room_on_current_floor(room_data) and _does_room_have_cleared_parent(room_data):
		_disable_button(false)
	else:
		_disable_button(true)
	


func _disable_button(is_disabled: bool):
	if icon == null or button == null:
		return
	
	button.disabled = is_disabled
	if not room_data.has_been_selected:
		icon.modulate.a = 0.5 if is_disabled else 1.0
	scale *= 1.0 if is_disabled else 1.4
	base_scale = scale

func _does_room_have_cleared_parent(room: RoomData) -> bool:
	var parents: Array[RoomData] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate: RoomData = GlobalData.current_map[room.row - 1][room.column - 1] as RoomData
		if parent_candidate.next_rooms.size() > 0:
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
	
	if room.column < map_generator.map_width - 1 and room.row > 0:
		var parent_candidate: RoomData = GlobalData.current_map[room.row - 1][room.column + 1] as RoomData
		if parent_candidate.next_rooms.size() > 0:
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
	
	if room.row > 0:
		var parent_candidate: RoomData = GlobalData.current_map[room.row - 1][room.column] as RoomData
		if parent_candidate.next_rooms.size() > 0:
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
	
	for parent in parents:
		if parent.has_been_selected:
			return true
	
	return false

func _is_room_on_current_floor(room: RoomData) -> bool:
	return room.row == GlobalData.floors_cleared


func _on_button_pressed() -> void:
	if room_data == null:
		return
	GlobalData.current_room = room_data
	if room_data.type == RoomData.Type.BOSS:
		SceneTransition.boss_transition(GlobalData.Scenes.COMBAT, GlobalData.Scenes.MAP)
	else:
		SceneTransition.transition(GlobalData.Scenes.COMBAT, GlobalData.Scenes.MAP)

func _process(_delta: float) -> void:
	if not button.disabled:
		pulsing_effect()
	else:
		scale = base_scale

func pulsing_effect():
	var time = Time.get_unix_time_from_system()
	var scale_offset: Vector2 = Vector2.ONE * sin(time * pulse_speed) * pulse_amount
	scale = base_scale + scale_offset
