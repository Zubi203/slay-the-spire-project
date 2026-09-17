class_name Card
extends Area2D

enum States {
	IDLE,
	HOVER,
	DRAGGING
}
var state: States

@export var card_data: CardData
@export var hover_sound: AudioStream
@export var drag_sound: AudioStream
@export var draw_sound: AudioStream
@export var discard_sound: AudioStream
@export var cast_particles: PackedScene
@export var tooltip_scene: PackedScene
@export var tooltip_delay: float = 0.2

@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel
@onready var icon: TextureRect = %Icon
@onready var type_label: Label = %TypeLabel
@onready var tooltip_container: VBoxContainer = %TooltipContainer

var default_z_index: int
var base_scale: Vector2
var idle_pos: Vector2
var hover_pos: Vector2
var idle_rotation: float
var tween: Tween

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func setup(data: CardData) -> void:
	card_data = data
	base_scale = scale
	state = States.IDLE
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", base_scale, 0.5).from(Vector2.ZERO)
	
	game_manager.EnergyChanged.emit(game_manager.current_energy, game_manager.max_energy)
	return_to_idle_pos()
	set_visuals()
	audio_manager.play_random_pitch(draw_sound)

func _ready() -> void:
	if game_manager:
		game_manager.EnergyChanged.connect(_on_energy_changed)

func _process(delta: float) -> void:
	var lerp_speed: float = 20
	var target_pos: Vector2 = idle_pos
	
	if state == States.DRAGGING:
		target_pos = get_global_mouse_position()
		global_position = global_position.lerp(target_pos, delta * lerp_speed)
	
	if state == States.HOVER:
		tooltip_container.show()
	else:
		tooltip_container.hide()
		
	update_description()

func cast():
	if game_manager.player == null or game_manager.enemy == null:
		return
	var cast_data: CardData.CastData = CardData.CastData.new()
	cast_data.caster = game_manager.player
	cast_data.opponent = game_manager.enemy
	card_data.cast(cast_data)
	
	if cast_particles:
		var particles: GPUParticles2D = cast_particles.instantiate()
		get_tree().current_scene.add_child(particles)
		particles.global_position = global_position

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
	update_description()

func update_description():
	
	description_label.text = ""
	

	var data: CardData.CastData = CardData.CastData.new()
	if game_manager.player:
		data.caster = game_manager.player
	if game_manager.enemy:
		data.opponent = game_manager.enemy
	
	if not card_data.override_auto_generated_description:
		description_label.text = card_data.get_description(data)
	
	if card_data.special_description and not card_data.override_auto_generated_description:
		description_label.text += ","

	if card_data.special_description:
		description_label.text += "\n" + card_data.special_description

func hover_enter():
	audio_manager.play_random_pitch(hover_sound)
	state = States.HOVER
	z_index = 99
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(self, "position", hover_pos, 0.2).from(idle_pos)
	tween.tween_property(self, "rotation_degrees", 0, 0.2)
	tween.tween_property(self, "scale", base_scale + Vector2.ONE * 0.3, 0.2).from(base_scale)
	tween.chain().tween_callback(update_tooltips).set_delay(tooltip_delay)


func hover_exit():
	state = States.IDLE
	return_to_idle_pos()
	clear_tooltips()

func drag_enter():
	audio_manager.play_random_pitch(drag_sound)
	state = States.DRAGGING
	z_index = 99
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 0, 0.2)
	tween.tween_property(self, "scale", base_scale + Vector2.ONE * 0.3, 0.2)

func drag_exit():
	state = States.IDLE
	return_to_idle_pos()
	

func return_to_idle_pos():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	z_index = default_z_index
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "position", idle_pos, 0.5)
	tween.tween_property(self, "rotation_degrees", idle_rotation, 0.5)
	tween.tween_property(self, "scale", base_scale, 0.2)

func _on_energy_changed(current: int, _max: int):
	if card_data.cost > current:
		cost_label.modulate = Color.RED
	else:
		cost_label.modulate = Color.WHITE

func flash_red():
	var flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color.RED, 0.1).from(Color.WHITE)
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func update_tooltips():
	
	clear_tooltips()
	
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
	tooltip.scale = Vector2.ONE * 0.5
	tooltip.base_scale = tooltip.scale
	tooltip.setup(status)
	
