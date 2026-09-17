class_name BlockFromMissingHPCardData
extends CardData

func cast (data : CastData):
	if data.opponent == null or data.caster == null:
		return
	
	var block_amount: int = data.caster.character_data.max_health - data.caster.current_health
	
	data.caster.block(block_amount)

func get_description(data: CastData) -> String:
	
	var amount: int = 0
	var block_number_text: String = ""
	if data.caster:
		amount = data.caster.character_data.max_health - data.caster.current_health
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
		block_number_text = "\nGain " + str(amount) + " Block."
	
	
	return "Gain Block equal to your missing health." + block_number_text

func get_preview_text(data: CastData = null) -> String:
	return ""

func check_cast_condition() -> bool:
	return true
