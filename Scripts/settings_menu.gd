extends Control

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider

@export var screen_shake_toggle: BaseButton
@export var custom_cursor_toggle: BaseButton

var master_index: int
var sfx_index: int
var music_index: int

func _ready() -> void:
	PauseManager.add_menu(self)
	
	master_index = AudioServer.get_bus_index("Master")
	sfx_index = AudioServer.get_bus_index("SFX")
	music_index = AudioServer.get_bus_index("Music")
	
	master_slider.value = get_volume(master_index)
	sfx_slider.value = get_volume(sfx_index)
	music_slider.value = get_volume(music_index)
	
	if screen_shake_toggle:
		screen_shake_toggle.button_pressed = GlobalData.screen_shake_enabled
	if custom_cursor_toggle:
		custom_cursor_toggle.button_pressed = GlobalData.custom_cursor_enabled

func _exit_tree() -> void:
	PauseManager.remove_menu(self)

func get_volume(bus_index: int) -> float:
	var volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume)

func set_volume(bus_index: int, volume: float):
	var db_volume = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_volume)


func _on_master_slider_value_changed(value: float) -> void:
	set_volume(master_index, value)


func _on_music_slider_value_changed(value: float) -> void:
	set_volume(music_index, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	set_volume(sfx_index, value)

func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)


func _on_close_button_pressed() -> void:
	close()


func _on_screen_shake_check_box_toggled(toggled_on: bool) -> void:
	GlobalData.screen_shake_enabled = toggled_on


func _on_custom_cursor_check_box_toggled(toggled_on: bool) -> void:
	GlobalData.custom_cursor_enabled = toggled_on

func close():
	PauseManager.remove_menu(self)
	_fade_out()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and PauseManager.is_current_menu(self) and PauseManager.state == PauseManager.State.PAUSED:
		close()
