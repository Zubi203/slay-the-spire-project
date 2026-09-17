class_name DrawAndEnergyPerBuffCardData
extends StatusCard

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	var activation_counter: int = 0
	for effect in data.caster.status_effects:
		activation_counter += 1
	
	for i in activation_counter:
		for j in cards_to_draw:
			card_manager._deal_card()
			await data.caster.get_tree().create_timer(0.2).timeout
		game_manager.current_energy += energy_gain

func get_description(data: CastData) -> String:
	return "\nDraw " + str(cards_to_draw) + " card(s) and gain " + str(energy_gain) + " energy for every status you have."
