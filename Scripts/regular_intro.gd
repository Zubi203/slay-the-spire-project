class_name RegularIntro
extends Panel

signal AnimationFinished

@export var intro_label: Label = null
var base_scale: Vector2

func _enter_tree() -> void:
	ManagerRegistry.register("intro", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("intro")

func _ready() -> void:
	base_scale = scale
	pivot_offset = size / 2

func _animate(display_text: String):
	if intro_label == null:
		return
	
	show()
	intro_label.text = display_text
	intro_label.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:y", base_scale.y, 0.6).from(0.0)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.4).from(0.0)
	
	tween.tween_property(intro_label, "modulate:a", 1.0, 0.5).from(0.0)
	tween.tween_interval(1)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(intro_label, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale:y", 0.0, 0.3)
	tween.tween_callback(animation_finished)

func animation_finished():
	hide()
	AnimationFinished.emit()
