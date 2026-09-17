class_name BlockGainOnZeroCardData
extends BlockCardData

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func get_description(data: CastData) -> String:
	
	var amount: int = block_amount
	if data.caster:
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
	
	var description: String = "If you have 0 block, "
	description += "Gain " + str(amount) + " block." 
	return description

func check_cast_condition() -> bool:
	var player: Character = game_manager.player
	if player.current_block <= 0:
		return true
	return false
