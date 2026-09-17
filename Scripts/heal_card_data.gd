class_name HealCardData
extends CardData

@export var heal_amount: int

func get_description(data: CastData) -> String:
	
	var amount: int = heal_amount
	if data.caster:
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.HEALING)
	
	
	var description: String
	description = "\nHeal " + str(amount) + " health."
	return description

func cast (data : CastData):
	data.caster.heal(heal_amount)

func get_preview_text(data: CastData = null) -> String:
	var amount: int = heal_amount
	if data.caster:
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.HEALING)
	
	return str(amount)

func check_cast_condition() -> bool:
	return true
