class_name DelayedDamageStatus
extends StatusEffect

@export var damage: int = 40

func get_description(host: Character = null) -> String:
	var amount: int = damage
	if host:
		var self_statuses: Array[ActiveEffect] = host.status_effects
		for status in self_statuses:
			if status.status_data is ModifierStatus:
				amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
	return "Deal " + str(amount) + " damage when this effect expires"

func on_remove(target: Character):
	if target == null:
		return
	target.take_damage(damage)
