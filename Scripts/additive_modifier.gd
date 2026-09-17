class_name AdditiveModifierStatus
extends ModifierStatus

@export var intensity: int = 2

func apply_status(target: Character):
	if target == null:
		return

	target.add_status_front(self)

func apply_modifier(_target: Character, stat: int, type: AffectedStat) -> int:
	if not type == stat_to_modify:
		return stat
	stat += intensity
	if not allow_negative:
		stat = clamp(stat, 1, 999)
	return stat

func get_description(host: Character = null) -> String:
	var result: String = ""
	var increase_type_string: String
	if intensity < 0:
		increase_type_string = "reduced"
	else:
		increase_type_string = "increased"
	
	result = get_modifier_stat_type_string() + " is " + increase_type_string + " by " + str(abs(intensity))
	return result
