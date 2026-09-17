class_name HealthBar
extends ProgressBar

@onready var health_label: Label = %HealthLabel
@onready var character: Character = get_parent()

func setup_ui() -> void:
	if character and character.character_data != null:
		if not character.HealthUpdated.is_connected(_update_ui):
			character.HealthUpdated.connect(_update_ui)
		max_value = character.character_data.max_health
	_update_ui.call_deferred()

func _update_ui():
	if character == null:
		return
	if health_label == null:
		return
	max_value = character.character_data.max_health
	value = character.current_health
	health_label.text = str(character.current_health) + "/" + str(character.character_data.max_health)
