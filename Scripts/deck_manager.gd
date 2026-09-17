extends Node

@export var base_deck: Array[CardData] 
@export var standard_rewards: Array[CardData] 
@export var special_rewards: Array[CardData] 
@export var healing_cards: Array[CardData] 
@export var all_cards: Array[CardData] 
var current_deck: Array[CardData]

func _ready() -> void:
	reset_deck()

func reset_deck():
	current_deck.clear()
	current_deck = base_deck.duplicate()

func add_card_to_deck(card: CardData):
	current_deck.append(card)

func remove_card_from_deck(card: CardData):
	current_deck.erase(card)

func get_current_deck() -> Array[CardData]:
	return current_deck.duplicate()

func get_all_cards() -> Array[CardData]:
	return all_cards.duplicate()

func get_standard_reward_pool() -> Array[CardData]:
	return standard_rewards.duplicate()

func get_special_reward_pool() -> Array[CardData]:
	return special_rewards.duplicate()

func get_heal_reward_pool() -> Array[CardData]:
	return healing_cards.duplicate()
