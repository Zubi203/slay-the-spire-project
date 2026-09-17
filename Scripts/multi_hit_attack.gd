class_name MultiHitAttack
extends AttackCardData

@export var number_of_hits: int = 2

func cast (data : CastData):
	for i in number_of_hits:
		if data.opponent == null or data.caster == null:
			return
		data.caster.attack(data.opponent, damage)
		await data.caster.get_tree().create_timer(0.6).timeout

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
	
	
	return "Deal " + str(amount) + " damage " + str(number_of_hits) + " times."

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
	
	return str(amount) + "x" + str(number_of_hits)
