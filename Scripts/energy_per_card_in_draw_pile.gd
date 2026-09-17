class_name EnergyPerCardInDrawPileCardData
extends CardData

@export var cards_per_energy: int = 5
var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")
var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	var energy_to_gain: int = floori(float(card_manager.draw_pile.size()) / float(cards_per_energy))
	game_manager.current_energy += energy_to_gain

func get_description(data: CastData) -> String:
	return "Gain 1 Energy for every " + str(cards_per_energy) + " cards in your draw pile."

func get_preview_text(data: CastData = null) -> String:
	return ""

func check_cast_condition() -> bool:
	return true
