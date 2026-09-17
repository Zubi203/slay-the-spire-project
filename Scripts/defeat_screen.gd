
extends Control

@export var defeat_label: Label = null
@export var button_container: HBoxContainer = null

var base_position: Vector2

func _ready() -> void:
	if defeat_label == null:
		return
	if button_container == null:
		return
	button_container.modulate.a = 0.0
	
	MusicManager.change_soundtrack(MusicManager.MusicTracks.DEFEAT)
	base_position = defeat_label.position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(defeat_label, "position:y", base_position.y, 2).from(base_position.y - 150)
	tween.parallel().tween_property(defeat_label, "modulate:a", 1.0, 1).from(0.0)
	tween.tween_property(button_container, "modulate:a", 1.0, 0.4).from(0.0)


func _on_play_again_button_pressed() -> void:
	GlobalData.reset_data()
	SceneTransition.transition(GlobalData.Scenes.MAP, GlobalData.Scenes.END_SCREEN)


func _on_main_menu_button_pressed() -> void:
	GlobalData.reset_data()
	SceneTransition.transition(GlobalData.Scenes.TITLE, GlobalData.Scenes.END_SCREEN)
