extends Node2D

@export var map_button_container: Node2D
@export var line_container: Node2D
@export var map_button_scene: PackedScene
@export var map_line_scene: PackedScene
@export var line_point_offset: float = 15

@export_category("Camera")
@export var camera: Camera2D
@export var scroll_speed: float = 15


var camera_limit_y: float
var camera_target_y: float
var floors_cleared: int = 0
var map_data: Array[Array] = []
var room_buttons: Array[MapButton]
var map_generator: MapGenerator:
	get: return ManagerRegistry.get_manager("map_generator")


func _ready() -> void:
	camera_limit_y = map_generator.distance_y * (map_generator.floors - 1)
	camera.position.x = map_generator.distance_x * floori(map_generator.map_width * 0.5)
	camera_target_y = -map_generator.distance_y * GlobalData.floors_cleared
	MusicManager.change_soundtrack(MusicManager.MusicTracks.MAP)
	room_buttons = []
	map_data = _get_map_data()
	_setup_rooms()
	set_paths()


func _get_map_data() -> Array[Array]:
	if GlobalData.current_map.is_empty():
		GlobalData.current_map = map_generator.generate_map()
	
	return GlobalData.current_map


func _setup_rooms():
	for i in map_generator.floors:
		for j in map_generator.map_width:
			var room: RoomData = map_data[i][j] as RoomData
			if room.next_rooms.size() > 0:
				spawn_room(room)
	
	var middle_idx: int = floori(map_generator.map_width * 0.5)
	spawn_room(map_data[map_generator.floors - 1][middle_idx])


func set_paths():
	if map_line_scene == null:
		return
	if line_container == null:
		return
	
	for room: MapButton in room_buttons:
		for next_room in room.room_data.next_rooms:
			var line: Line2D = map_line_scene.instantiate()
			line_container.add_child(line)
			var line_point_start: Vector2 = room.position
			var line_point_end: Vector2 = next_room.position
			
			var dir = line_point_start.direction_to(line_point_end)
			line_point_start = line_point_start + dir * line_point_offset
			var boss_room_offset_multiplier: float = 2.0 if next_room.type == RoomData.Type.BOSS else 1.0
			line_point_end = line_point_end - dir * line_point_offset * boss_room_offset_multiplier
			line.add_point(line_point_start)
			line.add_point(line_point_end)


func spawn_room(room: RoomData):
	if map_button_container == null:
		return
	if map_button_scene == null:
		return
	
	var button: MapButton = null
	
	for child in map_button_container.get_children():
		if child is MapButton and not child.visible:
			child.show()
			button = child
			break
	
	if button == null:
		button = map_button_scene.instantiate()
		map_button_container.add_child(button)
	
	room_buttons.append(button)
	button.button_setup(room)


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("scroll_up"):
		camera_target_y = camera.position.y - scroll_speed
	if Input.is_action_pressed("scroll_down"):
		camera_target_y = camera.position.y + scroll_speed
	camera_target_y = clampf(camera_target_y, -camera_limit_y, 0)


func _process(delta: float) -> void:
	camera.position.y = lerpf(camera.position.y, camera_target_y, delta * 10)
