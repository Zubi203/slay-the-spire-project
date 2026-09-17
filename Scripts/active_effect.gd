class_name ActiveEffect
extends RefCounted

var status_data: StatusEffect
var turns_remaining: int = 0

func _init(data: StatusEffect) -> void:
	status_data = data
	turns_remaining = data.base_duration
