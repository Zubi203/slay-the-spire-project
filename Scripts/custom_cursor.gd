extends Sprite2D



func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if GlobalData.custom_cursor_enabled:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
