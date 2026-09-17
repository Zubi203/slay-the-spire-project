class_name RoomData
extends Resource

enum Type{
	NOT_ASSIGNED,
	BOSS,
	COMBAT,
	REWARD,
	REST
}
@export var type: Type = Type.NOT_ASSIGNED
@export var row: int
@export var column: int
@export var next_rooms: Array[RoomData]
@export var position: Vector2
@export var has_been_selected: bool = false
