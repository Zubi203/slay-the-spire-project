class_name EnemyAI
extends Node

var enemy_actions: Array[CardData] = []
var current_action_index: int = -1
@export var cast_delay: float = 2

@export var preview_icon: TextureRect
@export var preview_label: Label
@export var preview_button: ActionPreview

@export var move_text_animation: PackedScene

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func _ready() -> void:
	game_manager.TurnEnd.connect(_on_turn_ended)
	game_manager.TurnStart.connect(_on_turn_start)

func _process(delta: float) -> void:
	set_preview_ui()

func setup_ai() -> void:
	get_deck.call_deferred()

func get_deck():
	if owner is Character:
		enemy_actions = owner.character_data.base_deck.duplicate()
	set_next_action()

func _on_turn_start(character: Character):
	if not character.character_data.is_player:
		perform_next_action()

func _on_turn_ended(character: Character):
	if not character.character_data.is_player:
		set_next_action()

func set_next_action():
	if enemy_actions.is_empty():
		return
	
	current_action_index += 1
	
	if current_action_index >= len(enemy_actions):
		current_action_index = 0

func perform_next_action():
	if enemy_actions.is_empty():
		return
	
	display_move_name()
	await get_tree().create_timer(cast_delay * 0.6).timeout
	
	var cast_data: CardData.CastData = CardData.CastData.new()
	var caster: Character
	if owner is Character:
		caster = owner
	else:
		caster = game_manager.enemy
	cast_data.caster = caster
	cast_data.opponent = game_manager.player
	
	if caster.defeated:
		return
	
	await enemy_actions[current_action_index].cast(cast_data)
	
	await get_tree().create_timer(cast_delay * 0.5).timeout
	
	game_manager.end_turn()

func set_preview_ui():
	if preview_icon == null:
		return
	if preview_label == null:
		return
	if preview_button == null:
		return
	
	var data: CardData.CastData = CardData.CastData.new()
	if game_manager.player:
		data.opponent = game_manager.player
	if game_manager.enemy:
		data.caster = game_manager.enemy
	
	preview_button.show()
	preview_button.setup(enemy_actions[current_action_index])
	preview_icon.texture = enemy_actions[current_action_index].icon
	preview_label.text = enemy_actions[current_action_index].get_preview_text(data)

func display_move_name():
	if move_text_animation == null:
		return
	var label: MoveTextEffect = move_text_animation.instantiate()
	get_tree().current_scene.add_child(label)
	label.global_position = owner.global_position + Vector2(-50, -50)
	label.animate(enemy_actions[current_action_index].name)
