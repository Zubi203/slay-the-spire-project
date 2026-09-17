extends CanvasLayer

@export var health_label: Label = null
@export var deck_label: Label = null

@export var reset_confirmation_scene: PackedScene
@export var card_display_scene: PackedScene

@export var pause_menu_scene: PackedScene

func _process(_delta: float) -> void:
	_update_labels()

func _update_labels():
	if health_label == null:
		return
	if deck_label == null:
		return
	
	health_label.text = str(GlobalData.current_health) + "/" + str(GlobalData.max_health)
	deck_label.text = str(DeckManager.current_deck.size())


func _on_reset_button_pressed() -> void:
	if reset_confirmation_scene == null:
		return
	
	var scene = reset_confirmation_scene.instantiate()
	add_child(scene)


func _on_settings_button_pressed() -> void:
	pause_game()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and PauseManager.state == PauseManager.State.UNPAUSED:
		pause_game()

func pause_game():
	if pause_menu_scene == null:
		return
	
	var scene = pause_menu_scene.instantiate()
	add_child(scene)

func _on_main_menu_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.TITLE, GlobalData.Scenes.MAP)


func _on_deck_button_pressed() -> void:
	if card_display_scene == null:
		return
	
	var display: CardDisplay = card_display_scene.instantiate()
	add_child(display)
	display.display_cards(DeckManager.get_current_deck(), "DECK")
