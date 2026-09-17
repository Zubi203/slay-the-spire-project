class_name NumberEffect
extends Label

@export var block_color: Color
@export var block_border_color: Color
@export var negative_color: Color
@export var negative_border_color: Color
@export var positive_color: Color
@export var positive_border_color: Color
@export var crit_color: Color
@export var crit_border_color: Color

@export var max_y_offset: float = -80
@export var max_x_offset: float = 30

var start_pos: Vector2
var base_scale: Vector2

func _ready() -> void:
	start_pos = position
	base_scale = scale
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

func animate(display_num: int, is_blocked: bool = false):
	if display_num == 0:
		label_settings.font_color = Color.WHITE
		label_settings.outline_color = Color.BLACK
	elif display_num > 0:
		label_settings.font_color = positive_color
		label_settings.outline_color = positive_border_color
	elif display_num < 0:
		if abs(display_num) >= 50:
			label_settings.font_color = crit_color
			label_settings.outline_color = crit_border_color
		else:
			label_settings.font_color = negative_color
			label_settings.outline_color = negative_border_color
	
	if is_blocked:
		label_settings.font_color = block_color
		label_settings.outline_color = block_border_color
	
	var display_text: String = str(abs(display_num))
	
	if abs(display_num) <= 15:
		label_settings.font_size = 16
		label_settings.outline_size = 6
	if abs(display_num) > 15 and abs(display_num) <= 30:
		label_settings.font_size = 24
		label_settings.outline_size = 8
	if abs(display_num) > 30 and abs(display_num) < 50:
		label_settings.font_size = 32
		label_settings.outline_size = 10
	if abs(display_num) >= 50:
		label_settings.font_size = 40
		label_settings.outline_size = 12
		display_text += "!"
	
	text = display_text
	var tween = create_tween()
	
	var offset_y = randf_range(0.6, 1.0) * max_y_offset
	var offset_x = randf_range(0, 1.0) * max_x_offset * [-1.0, 1.0].pick_random()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", base_scale, 0.2).from(Vector2.ZERO)
	tween.parallel().tween_property(self, "position:y", start_pos.y + offset_y, 0.6).from(start_pos.y)
	tween.parallel().tween_property(self, "position:x", start_pos.x + offset_x, 0.6).from(start_pos.x)
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3).from(base_scale)
	tween.tween_callback(queue_free).set_delay(2)
