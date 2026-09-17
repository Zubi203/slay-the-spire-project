class_name SelfDamageAttackCardData
extends AttackCardData

@export var self_damage: int = 3

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	data.caster.take_damage(self_damage)
	await data.caster.get_tree().create_timer(0.2).timeout
	data.caster.attack(data.opponent, damage)

func get_description(data: CastData) -> String:
	var description: String = ""
	
	if damage > 0:
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
		description += "\nDeal " + str(amount) + " damage." 
	
	if self_damage > 0:
		var amount: int = self_damage
		if data.caster:
			var self_statuses: Array[ActiveEffect] = data.caster.status_effects
			for status in self_statuses:
				if status.status_data is ModifierStatus:
					amount = status.status_data.apply_modifier(data.caster, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
		description += "\nLose " + str(amount) + " health." 
	
	return description

func check_cast_condition() -> bool:
	if game_manager.player.current_health <= self_damage:
		return false
	return true
