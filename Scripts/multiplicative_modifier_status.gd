class_name MultiplicativeModifierStatus
extends ModifierStatus

@export var multiplier: float = 1.25

func apply_modifier(_target: Character, stat: int, type: AffectedStat) -> int:
	if not type == stat_to_modify:
		return stat
	
	var stat_float: float = float(stat)
	var result: float = stat_float * multiplier
	if not allow_negative:
		result = clampf(result, 1, 999)
	return int(round(result))

func get_description(host: Character = null) -> String:
	var result: String = ""
	var increase_type_string: String = ""
	var number_string: String = ""
	
	if multiplier >= 1.0:
		increase_type_string = "increased"
		number_string = "+" + str(int(abs(1.0 - multiplier) * 100))
	else:
		increase_type_string = "reduced"
		number_string = "-" + str(int(abs(1.0 - multiplier) * 100))
	
	result = get_modifier_stat_type_string() + " is " + increase_type_string + " by " + number_string + "%"
	return result
