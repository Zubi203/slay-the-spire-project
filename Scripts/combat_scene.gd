extends Node2D

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func _ready() -> void:
	if GlobalData.current_room.type == RoomData.Type.COMBAT:
		MusicManager.change_soundtrack(MusicManager.MusicTracks.COMBAT)
	
	game_manager.begin_game()
