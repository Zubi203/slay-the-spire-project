class_name DoubleBlockCardData
extends CardData

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func cast (data : CastData):
	if data.caster == null:
		return
	
	data.caster.block(data.caster.current_block)

func get_description(data: CastData) -> String:
	return "Doubles your Block."

func get_preview_text(data: CastData = null) -> String:
	return "x2"

func check_cast_condition() -> bool:
	var player: Character = game_manager.player
	if player == null:
		return false
	if player.current_block <= 0:
		return false
	return true
