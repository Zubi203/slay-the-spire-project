class_name ModifierStatus
extends StatusEffect

enum AffectedStat {
	BLOCK,
	HEALING,
	ATTACK,
	INCOMING_DAMAGE
}

@export var stat_to_modify: AffectedStat
@export var allow_negative: bool = false

@warning_ignore("unused_parameter")
func apply_modifier(_target: Character, stat: int, type: AffectedStat) -> int:
	return stat

func get_description(host: Character = null) -> String:
	return ""

func get_modifier_stat_type_string() -> String:
	var result: String = ""
	match stat_to_modify:
		AffectedStat.BLOCK:
			result = "Block Gain"
		AffectedStat.HEALING:
			result = "Healing"
		AffectedStat.ATTACK:
			result = "Base Attack"
		AffectedStat.INCOMING_DAMAGE:
			result = "Incoming Damage"
	return result
