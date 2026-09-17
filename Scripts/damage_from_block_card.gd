class_name DamageFromBlockCardData
extends CardData

func cast (data : CastData):
	if data.opponent == null or data.caster == null:
		return
	
	data.caster.attack(data.opponent, data.caster.current_block)

func get_description(data: CastData) -> String:
	
	var amount: int = 0
	var damage_text: String = ""
	if data.caster:
		amount = data.caster.current_block
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.ATTACK)
	if data.opponent:
		var opponent_statuses: Array[ActiveEffect] = data.opponent.status_effects
		for status in opponent_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.opponent, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
	
	if data.caster != null:
		damage_text = "\nDeal " + str(amount) + " damage."
	
	return "Deal damage equal to the user's current Block." + damage_text

func get_preview_text(data: CastData = null) -> String:
	var amount: int = 0
	var damage_text: String = ""
	if data.caster:
		amount = data.caster.current_block
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.ATTACK)
	if data.opponent:
		var opponent_statuses: Array[ActiveEffect] = data.opponent.status_effects
		for status in opponent_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.opponent, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
	
	if data.caster:
		damage_text = str(amount)
	
	return damage_text

func check_cast_condition() -> bool:
	return true
