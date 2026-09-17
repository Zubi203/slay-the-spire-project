extends Control

@export var settings_scene: PackedScene
@export var card_display_scene: PackedScene

func _ready() -> void:
	MusicManager.change_soundtrack(MusicManager.MusicTracks.TITLE)

func _on_play_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.MAP, GlobalData.Scenes.TITLE)


func _on_compendium_button_pressed() -> void:
	if card_display_scene == null:
		return
	
	var display: CardDisplay = card_display_scene.instantiate()
	add_child(display)
	display.display_cards(DeckManager.get_all_cards(), "CARD COMPENDIUM")


func _on_settings_button_pressed() -> void:
	if settings_scene == null:
		return
	
	var scene = settings_scene.instantiate()
	add_child(scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
