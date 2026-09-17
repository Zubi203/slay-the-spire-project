class_name MultiplyEnergyCardData
extends CardData

@export var multiplier: int = 2
var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	game_manager.current_energy *= multiplier
	
	

func get_description(data: CastData) -> String:
	return ""

func get_preview_text(data: CastData = null) -> String:
	return "x" + str(multiplier)

func check_cast_condition() -> bool:
	return true
