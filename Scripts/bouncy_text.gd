extends Label

var base_scale: Vector2

func _ready() -> void:
	base_scale = scale
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2


func _set(property: StringName, value: Variant) -> bool:
	if property == &"text":
		if text != value:
			var tween = create_tween()
			tween.tween_property(self, "scale", base_scale + Vector2.ONE * 0.6, 0.1).from(base_scale)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(self, "scale", base_scale, 0.2)
		text = value
		
		return true
	
	return false
