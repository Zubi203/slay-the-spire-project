extends Control

@export var reset_confirmation_scene: PackedScene
@export var settings_scene: PackedScene
@export var card_display_scene: PackedScene

@export var buttons: Array[BaseButton] = []

func _ready() -> void:
	PauseManager.add_menu(self)

func _exit_tree() -> void:
	PauseManager.remove_menu(self)


func _on_resume_button_pressed() -> void:
	close()


func _on_settings_button_pressed() -> void:
	if settings_scene == null:
		return
	
	var scene = settings_scene.instantiate()
	add_child(scene)


func _on_reset_run_button_pressed() -> void:
	if reset_confirmation_scene == null:
		return
	
	var scene = reset_confirmation_scene.instantiate()
	add_child(scene)


func _on_compendium_button_pressed() -> void:
	if card_display_scene == null:
		return
	
	var display: CardDisplay = card_display_scene.instantiate()
	add_child(display)
	display.display_cards(DeckManager.get_all_cards(), "CARD COMPENDIUM")

func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)

func close():
	PauseManager.remove_menu(self)
	for button in buttons:
		button.disabled = true
	_fade_out()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and PauseManager.is_current_menu(self) and PauseManager.state == PauseManager.State.PAUSED:
		close.call_deferred()


func _on_main_menu_button_pressed() -> void:
	close()
	SceneTransition.transition(GlobalData.Scenes.TITLE, GlobalData.current_scene)
