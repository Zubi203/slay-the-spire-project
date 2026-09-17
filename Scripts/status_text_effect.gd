class_name StatusTextEffect
extends Label

var base_position: Vector2

@export var fade_in_offset: float = 20
@export var fade_out_offset: float = 10

@export var buff_font_color: Color
@export var buff_border_color: Color

@export var debuff_font_color: Color
@export var debuff_border_color: Color

func _ready() -> void:
	modulate.a = 0.0
	base_position = position
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

func animate(status: StatusEffect):
	
	match status.buff_type:
		StatusEffect.Type.BUFF:
			label_settings.font_color = buff_font_color
			label_settings.outline_color = buff_border_color
		StatusEffect.Type.DEBUFF:
			label_settings.font_color = debuff_font_color
			label_settings.outline_color = debuff_border_color
	
	var dir_multiplier: float = -1 if status.buff_type == StatusEffect.Type.BUFF else 1
	
	text = status.name
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.1).from(0.0)
	tween.parallel().tween_property(self, "position:y", base_position.y , 0.2).from(base_position.y - fade_in_offset * dir_multiplier)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.1).set_delay(0.5)
	tween.parallel().tween_property(self, "position:y", base_position.y + fade_out_offset * dir_multiplier, 0.1).set_delay(0.5)
	tween.tween_callback(queue_free).set_delay(1.8)
