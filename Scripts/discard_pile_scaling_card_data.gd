class_name DiscardPileScalingAttackCardData
extends AttackCardData

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

@export var damage_per_discarded_card: int = 2

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	var final_damage: int = damage
	for card: CardData in card_manager.discard_pile:
		final_damage += damage_per_discarded_card
	
	data.caster.attack(data.opponent, final_damage)

func get_description(data: CastData) -> String:
	var description: String = ""
	
	var amount: int = damage
	if data.caster:
		
		for card: CardData in card_manager.discard_pile:
			amount += damage_per_discarded_card
		
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
	description += "\nDeal " + str(damage_per_discarded_card) + " extra damage for each card in your discard pile."
	return description
