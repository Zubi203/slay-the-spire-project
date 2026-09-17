class_name CheckpointButton
extends Area2D

@export var animation_duration: float = 1.0
@onready var sprite: Sprite2D = %Sprite2D

var enabled: bool = true

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")
var tween: Tween
var base_scale: Vector2

func _ready() -> void:
	_pre_warm_particles()
	base_scale = scale

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if not enabled:
			return
		enabled = false
		checkpoint_clicked()

func checkpoint_clicked():
	pass

func _on_mouse_entered() -> void:
	if not enabled:
		return
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:x", base_scale.x + 0.2, animation_duration * 0.2)
	tween.parallel().tween_property(self, "scale:y", base_scale.x + 0.2, animation_duration * 0.35)


func _on_mouse_exited() -> void:
	if not enabled:
		return
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", base_scale, animation_duration * 0.3)

func _pre_warm_particles():
	pass
