class_name UIManager
extends CanvasLayer

@export var energy_label: Label
@export var draw_label: Label
@export var discard_label: Label
@export var end_turn_button: BaseButton
@export var card_reward_menu: PackedScene
@export var pause_menu_scene: PackedScene
@export var boss_intro: BossIntro

@export var card_display_scene: PackedScene

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func _enter_tree() -> void:
	ManagerRegistry.register("ui_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("ui_manager")

func _ready() -> void:
	card_manager.CardPilesChanged.connect(update_card_piles)
	game_manager.TurnEnd.connect(_disable_end_turn_button)
	game_manager.TurnStart.connect(_enable_end_turn_button)
	
	if GlobalData.current_room.type == RoomData.Type.REWARD or GlobalData.current_room.type == RoomData.Type.REST:
		end_turn_button.disabled = true


func update_energy_label(current: int, _maximum: int):
	if energy_label == null:
		return
	
	energy_label.text = str(current) + "/" + str(_maximum)
	
	if current <= 0:
		energy_label.modulate = Color.ORANGE_RED
	else:
		energy_label.modulate = Color.WHITE

func update_card_piles(draw: int, discard: int):
	if draw_label == null:
		return
	if discard_label == null:
		return
	
	draw_label.text = str(draw)
	discard_label.text = str(discard)

func _disable_end_turn_button(character: Character):
	if character.character_data.is_player:
		end_turn_button.disabled = true

func _enable_end_turn_button(character: Character):
	if GlobalData.current_room.type == RoomData.Type.REWARD or GlobalData.current_room.type == RoomData.Type.REST:
		return
	
	if character.character_data.is_player:
		end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	if not game_manager.current_character.character_data.is_player:
		return
	game_manager.end_turn()

func spawn_reward_menu(reward_type: CardRewardMenu.RewardType):
	if card_reward_menu == null:
		return
	
	var menu: CardRewardMenu = card_reward_menu.instantiate()
	add_child(menu)
	menu.set_rewards(reward_type)


func activate_boss_intro():
	if boss_intro == null:
		return
	boss_intro.show()


func _on_settings_button_pressed() -> void:
	_pause_game()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and PauseManager.state == PauseManager.State.UNPAUSED:
		_pause_game()


func _pause_game():
	if pause_menu_scene == null:
		return
	
	var scene = pause_menu_scene.instantiate()
	add_child(scene)

func _on_draw_pile_pressed() -> void:
	if card_display_scene == null:
		return
	if card_manager.draw_pile.is_empty():
		return
	
	var display: CardDisplay = card_display_scene.instantiate()
	add_child(display)
	display.display_cards(card_manager.draw_pile.duplicate(), "DRAW PILE")


func _on_discard_pile_pressed() -> void:
	if card_display_scene == null:
		return
	if card_manager.discard_pile.is_empty():
		return
	
	var display: CardDisplay = card_display_scene.instantiate()
	add_child(display)
	display.display_cards(card_manager.discard_pile.duplicate(), "DISCARD PILE")
