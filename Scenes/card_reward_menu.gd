class_name CardRewardMenu
extends Control

enum RewardType {
	STANDARD,
	SPECIAL,
	HEALING
}

var type: RewardType
@export var card_buttons: Array[CardButton] = []

@export var background: ColorRect = null
@export var text_label: Label

@export var select_sound: AudioStream
var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func _ready() -> void:
	
	for button in card_buttons:
		button.CardButtonPressed.connect(select_card)
	
	if background == null:
		return
	if text_label == null:
		return
	
	text_label.modulate.a = 0.0
	background.modulate.a = 0.0
	var base_pos: Vector2 = text_label.position
	for button in card_buttons:
		button.modulate.a = 0.0
		button.disabled = true
	
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(background, "modulate:a", 0.7, 0.4).from(0.0)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(text_label, "position:y", base_pos.y + 90, 0.4).from(base_pos.y - 30)
	tween.parallel().tween_property(text_label, "modulate:a", 1.0, 0.2).from(0.0)
	
	for button in card_buttons:
		
		var button_base_pos: Vector2 = button.position
		
		var button_tween = create_tween()
		tween.set_ignore_time_scale(true)
		button_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		button_tween.tween_property(button, "position:y", button_base_pos.y, 0.6).from(button_base_pos.y + 40)
		button_tween.parallel().tween_property(button, "modulate:a", 1.0, 0.4).from(0.0)
		await  get_tree().create_timer(0.1, true, false, true).timeout
	
	for button in card_buttons:
		button.disabled = false
	
	PauseManager.add_menu(self)

func set_rewards(reward_type: RewardType):
	var selected_rewards: Array[CardData] = []
	var reward_pool: Array[CardData] = []
	match reward_type:
		RewardType.STANDARD:
			reward_pool = DeckManager.get_standard_reward_pool()
		RewardType.SPECIAL:
			reward_pool = DeckManager.get_special_reward_pool()
		RewardType.HEALING:
			reward_pool = DeckManager.get_heal_reward_pool()
	for i in len(card_buttons):
		var reward: CardData = reward_pool.pick_random()
		while selected_rewards.has(reward):
			reward = reward_pool.pick_random()
		selected_rewards.append(reward)
		card_buttons[i].setup(reward)
	

func select_card(card_button: CardButton):
	PauseManager.remove_menu(self)
	DeckManager.add_card_to_deck(card_button.card_data)
	if audio_manager:
		audio_manager.play(select_sound)
	for button in card_buttons:
		if button == card_button:
			button.select_animation()
		else:
			button.exit_animation()
	
	await get_tree().create_timer(1, true, false, true).timeout
	SceneTransition.transition(GlobalData.Scenes.MAP, GlobalData.current_scene)

func _exit_tree() -> void:
	PauseManager.remove_menu(self)
