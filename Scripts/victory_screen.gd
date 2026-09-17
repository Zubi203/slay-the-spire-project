extends Control

@export var victory_label: Label
@export var flavor_text_label: Label
@export var button_container: HBoxContainer

@export_multiline var flavor_text_fast: String = ""
@export_multiline var flavor_text_slow: String = ""

var base_scale: Vector2

func _ready() -> void:
	if victory_label == null:
		return
	if button_container == null:
		return
	if flavor_text_label == null:
		return
	
	button_container.modulate.a = 0.0
	base_scale = victory_label.scale
	victory_label.pivot_offset.x = victory_label.size.x / 2
	victory_label.pivot_offset.y = victory_label.size.y * 2
	
	MusicManager.change_soundtrack(MusicManager.MusicTracks.VICTORY)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(victory_label, "scale", base_scale, 0.8).from(Vector2.ZERO)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(flavor_text_label, "text", flavor_text_fast, 1.5).from("")
	tween.parallel().tween_property(button_container, "modulate:a", 1.0, 0.4).from(0.0)
	tween.tween_interval(1)
	tween.tween_property(flavor_text_label, "text", flavor_text_fast + flavor_text_slow, 2)
	


func _on_play_again_button_pressed() -> void:
	GlobalData.reset_data()
	SceneTransition.transition(GlobalData.Scenes.MAP, GlobalData.Scenes.END_SCREEN)


func _on_main_menu_button_pressed() -> void:
	GlobalData.reset_data()
	SceneTransition.transition(GlobalData.Scenes.TITLE, GlobalData.Scenes.END_SCREEN)
