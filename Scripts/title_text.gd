extends Control

@export var pulse_speed: float = 1.5
@export var pulse_amount: float = 0.04
var base_scale: Vector2

func _ready() -> void:
	base_scale = scale

func _process(_delta: float) -> void:
	pulsing_effect()

func pulsing_effect():
	var time = Time.get_unix_time_from_system()
	var scale_offset: Vector2 = Vector2.ONE * sin(time * pulse_speed) * pulse_amount
	scale = base_scale + scale_offset
