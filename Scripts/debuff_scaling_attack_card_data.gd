class_name DebuffScalingAttackCardData
extends AttackCardData

@export var damage_per_debuff: int = 3

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	var damage_to_deal: int = damage
	for status in data.opponent.status_effects:
		damage_to_deal += damage_per_debuff
	
	data.caster.attack(data.opponent, damage_to_deal)

func get_description(data: CastData) -> String:
	var description: String = ""
	
	var amount: int = damage
	if data.opponent:
		for status in data.opponent.status_effects:
			amount += damage_per_debuff
	
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
	
	description += "\nDeal " + str(amount) + " damage.\n"
	description += "Deal " + str(damage_per_debuff) + " extra damage for every status inflicted on the target."
	return description
