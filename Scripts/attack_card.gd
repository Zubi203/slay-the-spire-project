class_name AttackCardData
extends CardData

@export var damage: int

func get_description(data: CastData) -> String:
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
	
	var description: String
	description = "\nDeal " + str(amount) + " damage." 
	return description

func cast (data : CastData):
	data.caster.attack(data.opponent, damage)

func get_preview_text(data: CastData = null) -> String:
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
	
	return str(amount)

func check_cast_condition() -> bool:
	return true
