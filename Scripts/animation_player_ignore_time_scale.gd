class_name AnimationPlayerIgnoreTimeScale
extends AnimationPlayer

func _process(_delta: float) -> void:
	if Engine.time_scale != 0.0:
		speed_scale = 1.0 / Engine.time_scale
	else:
		speed_scale = 1.0
