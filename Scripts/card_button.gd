class_name CardButton
extends TextureButton

signal CardButtonPressed(button: CardButton)

@export var card_data: CardData
@export var animate_on_ready: bool = false

@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel
@onready var icon: TextureRect = %Icon
@onready var type_label: Label = %TypeLabel

@export var tooltip_container: VBoxContainer
@export var tooltip_scene: PackedScene

var start_pos: Vector2
var base_scale: Vector2



func _ready() -> void:
	base_scale = scale
	start_pos = position
	pressed.connect(_on_pressed)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _enter_animation():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)

func setup(card: CardData):
	card_data = card
	set_visuals()

func set_visuals():
	if name_label == null:
		return
	if cost_label == null:
		return
	if card_data == null:
		return
	if description_label == null:
		return
	if icon == null:
		return
	if type_label == null:
		return
	
	name_label.text = card_data.name
	cost_label.text = str(card_data.cost)
	icon.texture = card_data.icon
	type_label.text = CardData.CardType.find_key(card_data.type)
	
	description_label.text = ""
	
	var data: CardData.CastData = CardData.CastData.new()
	data.caster = null
	data.opponent = null
	
	if not card_data.override_auto_generated_description:
		description_label.text = card_data.get_description(data)
	

	if card_data.special_description:
		description_label.text += "\n" + card_data.special_description 

func update_tooltips():
	for status in card_data.tooltip_statuses:
		set_status_tooltip(status)
	
	if card_data is StatusCard:
		for status in card_data.buffs_to_apply:
			set_status_tooltip(status)
		for status in card_data.debuffs_to_apply:
			set_status_tooltip(status)

func clear_tooltips():
	if tooltip_container == null:
		return
	
	for child in tooltip_container.get_children():
		child.queue_free()

func set_status_tooltip(status: StatusEffect):
	if tooltip_container == null:
		return
	
	if tooltip_scene == null:
		return
	
	var tooltip: StatusTooltip = tooltip_scene.instantiate()
	tooltip_container.add_child(tooltip)
	tooltip.setup(status)

func _on_pressed():
	CardButtonPressed.emit(self)

func exit_animation():
	disabled = true
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", start_pos.y + 100, 0.5).from(start_pos.y)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)

func select_animation():
	disabled = true
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", base_scale + Vector2.ONE * 0.4, 0.8)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)

func _mouse_entered():
	if tooltip_container:
		update_tooltips()
		tooltip_container.show()

func _mouse_exited():
	if tooltip_container:
		clear_tooltips()
		tooltip_container.hide()

func _pressed() -> void:
	if tooltip_container:
		tooltip_container.hide()
