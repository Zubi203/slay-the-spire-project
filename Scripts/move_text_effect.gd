class_name MoveTextEffect
extends Label

var base_scale: Vector2

func _ready() -> void:
	modulate.a = 0.0
	base_scale = scale
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

func animate(display_text: String):
	text = display_text
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).from(0.0)
	tween.parallel().tween_property(self, "scale", base_scale, 0.5).from(Vector2.ZERO)
	tween.tween_interval(1.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free).set_delay(2)
