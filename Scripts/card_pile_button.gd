extends TextureButton

@export var tooltip: Control
var tween: Tween

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _mouse_entered():
	if tooltip == null:
		return
	
	tooltip.show()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(tooltip, "scale", Vector2.ONE, 0.15).from(Vector2.ZERO)
	
func _mouse_exited():
	if tooltip == null:
		return
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(tooltip, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(tooltip.hide)
