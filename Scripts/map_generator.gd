class_name MapGenerator
extends Node

@export var distance_x: float = 30
@export var distance_y: float = 25
@export var random_offset_distance: float = 5
@export var floors: int = 15
@export var map_width: int = 7
@export var num_paths: int = 6
@export var room_weights: Dictionary[RoomData.Type, float] = {
	RoomData.Type.COMBAT: 15.0,
	RoomData.Type.REWARD: 2.5,
	RoomData.Type.REST: 4.0
}
var map_data: Array[Array] 

func _enter_tree() -> void:
	ManagerRegistry.register("map_generator", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("map_generator")

func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points: Array[int] = _get_path_start_points()
	
	for j in starting_points:
		var current_j: int = j
		for i in floors - 1:
			current_j = _setup_connection(i, current_j)
	
	_setup_boss_room()
	_setup_room_types()
	return map_data

func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	for i in floors:
		var floor_rooms: Array[RoomData] = []
		for j in map_width:
			var current_room: RoomData = RoomData.new()
			var offset: Vector2 = Vector2(randf(), randf()) * random_offset_distance
			current_room.position = Vector2(j * distance_x, i * -distance_y) + offset
			current_room.column = j
			current_room.row = i
			current_room.next_rooms = []
			if i == floors - 1:
				current_room.position.y = (i + 1) * -distance_y
			floor_rooms.append(current_room)
		result.append(floor_rooms)
	return result

func _get_path_start_points() -> Array[int]:
	var x_coordinates: Array[int]
	var unique_points: int = 0
	while unique_points < 2:
		x_coordinates = []
		unique_points = 0
		for i in num_paths:
			var starting_point: int = randi_range(0, map_width - 1)
			if not x_coordinates.has(starting_point):
				unique_points += 1
			x_coordinates.append(starting_point)
	return x_coordinates

func _setup_connection(i: int, j: int) -> int:
	var next_room: RoomData = null
	var current_room: RoomData = map_data[i][j] as RoomData
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j: int = clampi(randi_range(j - 1, j + 1), 0, map_width - 1)
		next_room = map_data[i + 1][random_j]
	
	current_room.next_rooms.append(next_room)
	return next_room.column

func _would_cross_existing_path(i: int, j: int, next_room: RoomData) -> bool:
	var left_neighbor: RoomData = null
	var right_neighbor: RoomData = null
	
	if j > 0:
		left_neighbor = map_data[i][j - 1]
	
	if j < map_width - 1:
		right_neighbor = map_data[i][j + 1]
	
	if left_neighbor and next_room.column < j:
		for room in left_neighbor.next_rooms:
			if room.column > next_room.column:
				return true
	
	if right_neighbor and next_room.column > j:
		for room in right_neighbor.next_rooms:
			if room.column < next_room.column:
				return true
		
	return false


func _setup_boss_room():
	var middle_index: int = floori(map_width * 0.5)
	var boss_room: RoomData = map_data[floors - 1][middle_index] as RoomData
	for j in map_width:
		var current_room: RoomData = map_data[floors - 2][j] as RoomData
		current_room.next_rooms = [] as Array[RoomData]
		if _has_previous_parent(current_room):
			current_room.next_rooms.append(boss_room)
	boss_room.type = RoomData.Type.BOSS

func _has_previous_parent(room: RoomData) -> bool:
	var parents: Array[RoomData] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column - 1] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.column < map_width - 1 and room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column + 1] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if parents.is_empty():
		return false
	
	return true

func _setup_room_types():
	for i in floors:
		for j in map_width:
			var current_room: RoomData = map_data[i][j] as RoomData
			if not current_room.next_rooms.size() > 0:
				continue
			if i == 0:
				current_room.type = RoomData.Type.COMBAT
			if i == (floors - 2):
				current_room.type = RoomData.Type.REST
			if i == floori(floors * 0.5):
				current_room.type = RoomData.Type.REWARD
	
	for current_floor in map_data:
		for floor_room: RoomData in current_floor:
			for next_room: RoomData in floor_room.next_rooms:
				if next_room.type == RoomData.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)
	

func _set_room_randomly(room: RoomData):
	var consecutive_rest: bool = true
	var consecutive_reward: bool = true
	var rest_at_3rd_to_last_floor: bool = true
	var rest_below_4: bool = true
	
	var type_candidate: RoomData.Type
	
	while consecutive_rest or consecutive_reward or rest_at_3rd_to_last_floor or rest_below_4:
		type_candidate = _get_random_type_by_weight()
		var has_rest_parent: bool = _room_has_parent_of_type(room, RoomData.Type.REST)
		var has_reward_parent: bool = _room_has_parent_of_type(room, RoomData.Type.REWARD)
		var is_reward: bool = type_candidate == RoomData.Type.REWARD
		var is_rest: bool = type_candidate == RoomData.Type.REST
		
		consecutive_rest = is_rest and has_rest_parent
		consecutive_reward = is_reward and has_reward_parent
		rest_at_3rd_to_last_floor = is_rest and room.row == floors - 3
		rest_below_4 = is_rest and room.row < 3
	
	room.type = type_candidate


func _get_random_type_by_weight() -> RoomData.Type:
	var total_weight: float = 0
	var cumulative_weights: float = 0
	
	for key in room_weights.keys():
		total_weight += room_weights[key]
	
	var random_roll: float = randf_range(0, total_weight)
	
	for key: RoomData.Type in room_weights.keys():
		cumulative_weights +=  room_weights[key]
		if random_roll < cumulative_weights:
			return key
	
	return RoomData.Type.COMBAT

func _room_has_parent_of_type(room: RoomData, type: RoomData.Type) -> bool:
	var parents: Array[RoomData] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column - 1] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.column < map_width - 1 and room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column + 1] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.row > 0:
		var parent_candidate: RoomData = map_data[room.row - 1][room.column] as RoomData
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	for parent: RoomData in parents: 
		if parent.type == type:
			return true
	
	return false
