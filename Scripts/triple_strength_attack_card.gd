class_name MultiModifierAttackCard
extends AttackCardData

@export var strength_counter: int = 3
@export var modifier_to_multiply: String = "Strength"

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	var final_damage: int = damage
	
	for status in data.caster.status_effects:
		if status.status_data is ModifierStatus:
			if not status.status_data.name.to_lower() == modifier_to_multiply.to_lower():
				continue
			for i in strength_counter - 1:
				final_damage = status.status_data.apply_modifier(data.caster, final_damage, ModifierStatus.AffectedStat.ATTACK)
	
	data.caster.attack(data.opponent, final_damage)

func get_description(data: CastData) -> String:
	var description: String = ""
	
	var amount: int = damage
	if data.caster:
		
		for status in data.caster.status_effects:
			if status.status_data is ModifierStatus:
				if not status.status_data.name.to_lower() == modifier_to_multiply.to_lower():
					continue
				for i in strength_counter - 1:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.ATTACK)
		
		var self_statuses: Array[ActiveEffect] = data.caster.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.ATTACK)
	if data.opponent:
		var opponent_statuses: Array[ActiveEffect] = data.opponent.status_effects
		for status in opponent_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(data.opponent, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
	
	
	description += "\nDeal " + str(amount) + " damage.\n"
	description += modifier_to_multiply + " affects this card " + str(strength_counter) + " times."
	return description
