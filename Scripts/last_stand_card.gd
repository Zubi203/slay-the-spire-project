class_name LastStandCardData
extends CardData

func cast (data : CastData):
	if data.opponent == null or data.caster == null:
		return
	
	var health_to_lose: int = data.caster.current_health - 1
	data.caster.current_health -= health_to_lose
	await  data.caster.get_tree().create_timer(0.1).timeout
	data.caster.block(2 * health_to_lose)

func get_description(data: CastData) -> String:
	
	var amount: int = 0
	var block_amount_string: String = ""
	if data.caster:
		
		amount = 2 * (data.caster.current_health - 1)
		
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.BLOCK)
		block_amount_string = "\nGain " + str(amount) + " Block."
	
	return "Reduce your health to 1 and gain block equal to twice the amount of health lost." + block_amount_string

func get_preview_text(data: CastData = null) -> String:
	return ""

func check_cast_condition() -> bool:
	return true
