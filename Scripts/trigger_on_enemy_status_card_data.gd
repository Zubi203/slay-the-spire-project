class_name TriggerOnEnemyStatusCardData
extends StatusCard

@export var status_to_search: StatusEffect = null



func check_cast_condition() -> bool:
	var enemy: Character = game_manager.enemy
	for status in enemy.status_effects:
		if status.status_data.name == status_to_search.name:
			return true
	return false

func get_description(data: CastData) -> String:
	var description: String = ""
	
	if damage > 0:
		var amount: int = damage
		if data.caster:
			var self_statuses: Array[ActiveEffect] = data.caster.status_effects
			for status in self_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.ATTACK)
		if data.opponent:
			var opponent_statuses: Array[ActiveEffect] = data.opponent.status_effects
			for status in opponent_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.opponent, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
		description += "\nDeal " + str(amount) + " damage." 
	
	if block > 0:
		var amount: int = block
		if data.caster:
			var self_statuses: Array[ActiveEffect] = data.caster.status_effects
			for status in self_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
		description += "\nGain " + str(amount) + " block." 
	
	if heal > 0:
		var amount: int = heal
		if data.caster:
			var self_statuses: Array[ActiveEffect] = data.caster.status_effects
			for status in self_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.HEALING)
		description += "\nHeal " + str(amount) + " health." 
	
	if self_damage > 0:
		var amount: int = self_damage
		if data.caster:
			var self_statuses: Array[ActiveEffect] = data.caster.status_effects
			for status in self_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
		description += "\nLose " + str(amount) + " health." 
	
	description += "\nIf the target has " + status_to_search.name + ","
	
	if energy_gain > 0:
		description += "\nGain " + str(energy_gain) + " energy." 
	if cards_to_draw > 0:
		description += "\nDraw " + str(cards_to_draw) + " card(s)." 
	
	for status in debuffs_to_apply:
		description += "Inflict " + status.name + "."
	for status in buffs_to_apply:
		description += "Gain " + status.name + "."
	return description
