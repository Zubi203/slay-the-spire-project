class_name StatusTooltip
extends PanelContainer

@export var status_data: StatusEffect

@onready var icon: TextureRect = %Icon
@onready var label: RichTextLabel = %StatusTooltipText

var base_scale


func _ready() -> void:
	#pivot_offset.y = size.y / 2
	base_scale = scale

func setup(status: StatusEffect):
	if status == null:
		return
	status_data = status
	icon.texture = status_data.icon
	
	label.text = "[b]" + status_data.name + "[/b]\n" 
	if not status_data.override_base_description:
		label.text += status_data.get_description() + ".\n"
	
	if status_data.description:
		label.text += status_data.description + ".\n"
	
	if status_data.base_duration > 0:
		label.text += "Duration: " + str(status_data.base_duration) + " turn(s)."
