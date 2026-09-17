class_name StatGainOnCardCastStatus
extends StatusEffect

enum EffectType{
	DAMAGE,
	BLOCK,
	HEALING,
}

@export var trigger_card_type: CardData.CardType
@export var stat_to_gain: EffectType
@export var stat_gain: int = 3
var stat_target: Character = null

var card_interactor: CardInteractor:
	get: return ManagerRegistry.get_manager("card_interactor")

func apply_status(target: Character):
	if target == null:
		return
	
	target.add_status(self)
	stat_target = target
	if not card_interactor.CardCasted.is_connected(_on_card_casted):
		card_interactor.CardCasted.connect(_on_card_casted)
	

func get_description(host: Character = null) -> String:
	var result: String = "Whenever a " + CardData.CardType.find_key(trigger_card_type) + " card is played, "
	match stat_to_gain:
		EffectType.DAMAGE:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
			result += "Take " + str(amount) + " damage "
			
		EffectType.HEALING:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.HEALING)
			result += "Heal " + str(amount) + " health "
			
		EffectType.BLOCK:
			var amount: int = stat_gain
			if host:
				var self_statuses: Array[ActiveEffect] = host.status_effects
				for status in self_statuses:
					if status.status_data is ModifierStatus:
						amount = status.status_data.apply_modifier(host, amount, ModifierStatus.AffectedStat.BLOCK)
			result += "Gain " + str(amount) + " block "
			
	return result

func _on_card_casted(card: CardData):
	if stat_target == null or card == null:
		return
	
	if not card.type == trigger_card_type:
		return
	
	await stat_target.get_tree().create_timer(0.05).timeout
	
	match stat_to_gain:
		EffectType.DAMAGE:
			stat_target.take_damage(stat_gain)
		EffectType.BLOCK:
			stat_target.block(stat_gain)
		EffectType.HEALING:
			stat_target.heal(stat_gain)

func on_remove(_target: Character):
	if card_interactor.CardCasted.is_connected(_on_card_casted):
		card_interactor.CardCasted.disconnect(_on_card_casted)
	stat_target = null
