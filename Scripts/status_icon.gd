class_name StatusIcon
extends Button

var status_effect: ActiveEffect
var count: int = 1
var turns_left: int = 0
var status_host: Character = null

@onready var icon_texture: TextureRect = %Icon
@onready var status_label: Label = %Label
@onready var description_label: RichTextLabel = %DescriptionText
@onready var description_panel: PanelContainer = %DescriptionPanel
var base_scale: Vector2
var base_position: Vector2

var panel_tween: Tween

func _ready() -> void:
	base_scale = description_panel.scale
	base_position = position

func _process(_delta: float) -> void:
	_update_description()

func setup(data: ActiveEffect, host: Character = null):
	if data == null:
		return
	if data.status_data == null:
		return
	if icon_texture == null or status_label == null:
		return
	
	if data.turns_remaining <= 0:
		count -= 1
		if count <= 0:
			remove()
	
	status_effect = data
	status_host = host
	icon_texture.texture = status_effect.status_data.icon
	status_label.visible = true if count > 1 else false
	
	
	
	status_label.text = str(count)
	if not visible:
		enter_animation()

func _update_description():
	if status_effect == null:
		return
	if status_effect.status_data == null:
		return
	
	description_label.text = "[b]" + status_effect.status_data.name + "[/b]\n" 
	if not status_effect.status_data.override_base_description:
		description_label.text += status_effect.status_data.get_description(status_host) + ".\n"
		
	if status_effect.status_data.description:
		description_label.text += status_effect.status_data.description + ".\n"
	
	description_label.text += "Turns left: " + str(status_effect.turns_remaining) 
	

func enter_animation():
	show()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.2).from(0.0)

func remove():
	queue_free()


func _on_mouse_entered() -> void:
	if panel_tween and panel_tween.is_running():
		panel_tween.kill()
	
	panel_tween = create_tween()
	description_panel.show()
	panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	panel_tween.tween_property(description_panel, "scale:x", base_scale.x, 0.15)
	panel_tween.parallel().tween_property(description_panel, "scale:y", base_scale.y, 0.2)

func _on_mouse_exited() -> void:
	if panel_tween and panel_tween.is_running():
		panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(description_panel, "scale", Vector2.ZERO, 0.1)
	panel_tween.tween_callback(description_panel.hide).set_delay(0.1)
