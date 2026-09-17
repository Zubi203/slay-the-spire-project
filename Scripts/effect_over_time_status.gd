class_name EffectOverTimeStatus
extends StatusEffect

enum EffectType {
	DAMAGE,
	HEALING,
	BLOCK,
	ENERGY,
	DRAW
}

enum TriggerOn {
	TURN_START,
	TURN_END
}


@export var effect_type: EffectType
@export var stat_gain: int = 3
@export var trigger_on: TriggerOn

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

func on_turn_end(target: Character):
	if trigger_on == TriggerOn.TURN_START:
		return
	
	match effect_type:
		EffectType.DAMAGE:
			target.take_damage(stat_gain)
		EffectType.HEALING:
			target.heal(stat_gain)
		EffectType.BLOCK:
			target.block(stat_gain)
		EffectType.ENERGY:
			game_manager.current_energy += stat_gain
		EffectType.DRAW:
			for i in stat_gain:
				card_manager._deal_card()
				await target.get_tree().create_timer(0.2).timeout

func on_turn_start(target: Character):
	if trigger_on == TriggerOn.TURN_END:
		return
	
	match effect_type:
		EffectType.DAMAGE:
			target.take_damage(stat_gain)
		EffectType.HEALING:
			target.heal(stat_gain)
		EffectType.BLOCK:
			target.block(stat_gain)
		EffectType.ENERGY:
			game_manager.current_energy += stat_gain
		EffectType.DRAW:
			for i in stat_gain:
				card_manager._deal_card()
				await target.get_tree().create_timer(0.2).timeout

func get_description(host: Character = null) -> String:
	var desc: String = ""
	match effect_type:
		EffectType.DAMAGE:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
			desc += "Take " + str(amount) + " damage "
			
		EffectType.HEALING:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.HEALING)
			desc += "Heal " + str(amount) + " health "
			
		EffectType.BLOCK:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.BLOCK)
			desc += "Gain " + str(amount) + " block "
			
		EffectType.ENERGY:
			desc += "Gain " + str(stat_gain) + " extra energy "
		EffectType.DRAW:
			desc += "Draw " + str(stat_gain) + " extra card(s) "
	match trigger_on:
		TriggerOn.TURN_START:
			desc += " at the start of every turn"
		TriggerOn.TURN_END:
			desc += " at the end of every turn"
	return desc
