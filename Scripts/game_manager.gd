class_name GameManager
extends Node

signal EnergyChanged (cur: int, max: int)
signal TurnEnd (character: Character)
signal TurnStart (character: Character)

@export var player: Character
var enemy: Character
@export var enemy_spawn_point: Node2D
@export var player_spawn_point: Node2D
var current_character: Character = null

@export var max_energy: int = 3
var current_energy: int:
	set(value):
		current_energy = value
		EnergyChanged.emit(current_energy, max_energy)
var game_over: bool = false

@export var enemy_scene: PackedScene
@export var player_scene: PackedScene
@export var reward_scene: PackedScene
@export var rest_scene: PackedScene

@export var easy_enemies: Array[CharacterData]
@export var hard_enemies: Array[CharacterData]
@export var boss_enemy: CharacterData
@export var player_data: CharacterData

@export var max_health_gain_on_rest: int = 10
@export var healing_percent_on_rest: float = 0.4
var ui_manager: UIManager:
	get: return ManagerRegistry.get_manager("ui_manager")

var intro: RegularIntro:
	get: return ManagerRegistry.get_manager("intro")

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")
func _enter_tree() -> void:
	ManagerRegistry.register("game_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("game_manager")
	if player:
		GlobalData.current_health = player.current_health
		GlobalData.max_health = player.character_data.max_health

func begin_game() -> void:
	EnergyChanged.connect(ui_manager.update_energy_label)
	spawn_enemy()
	spawn_player()
	
	if enemy != null and enemy.character_data.display_entry_text:
		await get_tree().create_timer(1.2).timeout
		intro._animate(enemy.character_data.entry_text + " appears!")
		await intro.AnimationFinished
	
	if enemy != null and GlobalData.current_room.type == RoomData.Type.BOSS:
		ui_manager.activate_boss_intro()
		await get_tree().create_timer(3.5).timeout
	
	
	
	next_turn.call_deferred()

func spend_energy(cost: int):
	current_energy -= cost

func reset_energy():
	current_energy = max_energy


func next_turn():
	if game_over:
		return
	
	if current_character == null:
		current_character = player
	else:
		current_character = player if current_character == enemy else enemy
	
	if current_character == null:
		return
	
	if current_character == player:
		reset_energy()
	
	current_character.activate_highlight()
	TurnStart.emit(current_character)

func end_turn():
	TurnEnd.emit(current_character)
	current_character.deactivate_higlight()
	next_turn()

func spawn_enemy():
	var should_spawn_enemy: bool = false
	match GlobalData.current_room.type:
		RoomData.Type.REWARD:
			var chest: CheckpointButton = reward_scene.instantiate()
			enemy_spawn_point.add_child(chest)
			chest.global_position = enemy_spawn_point.global_position
		RoomData.Type.REST:
			var campfire: CheckpointButton = rest_scene.instantiate()
			enemy_spawn_point.add_child(campfire)
			campfire.global_position = enemy_spawn_point.global_position
		RoomData.Type.COMBAT:
			should_spawn_enemy = true
		RoomData.Type.BOSS:
			should_spawn_enemy = true
	
	if not should_spawn_enemy:
		return
	
	var dino: Character = enemy_scene.instantiate()
	enemy_spawn_point.add_child(dino)
	dino.global_position = enemy_spawn_point.global_position
	enemy = dino
	
	if enemy == null:
		return
	
	enemy.CharcterDefeated.connect(_on_enemy_defeated)
	
	if GlobalData.current_room.type == RoomData.Type.BOSS:
		enemy.setup(boss_enemy)
		return
	
	if not GlobalData.current_room.type == RoomData.Type.COMBAT:
		return
	
	var consecutive_enemy: bool = true
	while consecutive_enemy:
		if GlobalData.current_room.row < 5:
			enemy.setup(easy_enemies.pick_random())
		else:
			enemy.setup(hard_enemies.pick_random())
		consecutive_enemy = enemy.character_data == GlobalData.previous_enemy
	
	GlobalData.previous_enemy = enemy.character_data
	
func spawn_player():
	if player_spawn_point == null:
		return
	if player_scene == null:
		return
	var player_instance: Character = player_scene.instantiate()
	player_spawn_point.add_child(player_instance)
	player_instance.global_position = player_spawn_point.global_position
	player_instance.setup(player_data)
	player = player_instance
	player.CharcterDefeated.connect(_on_player_defeated)
	
	player.character_data.max_health = GlobalData.max_health
	player.current_health = GlobalData.current_health

func _on_enemy_defeated():
	if game_over:
		return
	game_over = true
	GlobalData.room_cleared()
	await get_tree().create_timer(0.5).timeout
	
	intro._animate("Battle Won!")
	await intro.AnimationFinished
	
	if GlobalData.current_room.type == RoomData.Type.BOSS:
		SceneTransition.slow_transition(GlobalData.Scenes.VICTORY_SCREEN, GlobalData.Scenes.COMBAT)
	else:
		ui_manager.spawn_reward_menu(CardRewardMenu.RewardType.STANDARD)

func _on_player_defeated():
	if game_over:
		return
	game_over = true
	await get_tree().create_timer(1).timeout
	GlobalData.reset_data()
	SceneTransition.slow_transition(GlobalData.Scenes.END_SCREEN, GlobalData.Scenes.COMBAT)

func _on_reward_button_pressed():
	if game_over:
		return
	game_over = true
	GlobalData.room_cleared()
	await get_tree().create_timer(0.5).timeout
	
	intro._animate("Treasure Discovered!")
	await intro.AnimationFinished
	
	ui_manager.spawn_reward_menu(CardRewardMenu.RewardType.SPECIAL)

func _on_rest_button_pressed():
	if game_over:
		return
	game_over = true
	player.character_data.max_health += max_health_gain_on_rest
	player.heal(int(healing_percent_on_rest * float(player.character_data.max_health)))
	GlobalData.room_cleared()
	await get_tree().create_timer(0.5).timeout
	
	intro._animate("Rest Site Found!")
	await intro.AnimationFinished
	
	ui_manager.spawn_reward_menu(CardRewardMenu.RewardType.HEALING)
