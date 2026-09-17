extends Control

@export var buttons: Array[BaseButton] = []

func _ready() -> void:
	PauseManager.add_menu(self)

func _exit_tree() -> void:
	PauseManager.remove_menu(self)

func _on_reset_button_pressed() -> void:
	PauseManager.clear_all_menus()
	GlobalData.reset_data()
	SceneTransition.transition(GlobalData.Scenes.MAP, GlobalData.current_scene)

func _on_cancel_button_pressed() -> void:
	close()

func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)

func close():
	PauseManager.remove_menu(self)
	for button in buttons:
		button.disabled = true
	_fade_out()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and PauseManager.is_current_menu(self) and PauseManager.state == PauseManager.State.PAUSED:
		close()
