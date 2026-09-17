class_name BlockCardData
extends CardData

@export var block_amount: int

func get_description(data: CastData) -> String:
	
	var amount: int = block_amount
	if data.caster:
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
	
	var description: String
	description = "\nGain " + str(amount) + " block." 
	return description

func cast (data : CastData):
	data.caster.block(block_amount)

func get_preview_text(data: CastData = null) -> String:
	var amount: int = block_amount
	if data.caster:
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
	
	return str(amount)

func check_cast_condition() -> bool:
	return true
