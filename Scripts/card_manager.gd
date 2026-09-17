class_name CardManager
extends Node

signal CardPilesChanged (draw: int, discard: int)

@export var cards_to_deal: int = 5
@export var card_scene: PackedScene
@export var max_hand_width: float = 400
@export var x_offset: float
@export var y_offset: float
@export var y_offset_curve: Curve
@export var max_rotation_degrees: float = 20
@export var rotation_curve: Curve

var discard_pile: Array[CardData]
var draw_pile: Array[CardData]

var card_nodes: Array[Card]

@onready var card_origin: Node2D = %CardOrigin
@onready var card_spawn: Node2D = %CardSpawn

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func _enter_tree() -> void:
	ManagerRegistry.register("card_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("card_manager")


func _ready() -> void:
	draw_pile = DeckManager.get_current_deck()
	draw_pile.shuffle()
	CardPilesChanged.emit(draw_pile.size(), discard_pile.size())
	game_manager.TurnEnd.connect(_on_turn_end)
	game_manager.TurnStart.connect(_on_turn_start)

func _rearrange_cards():
	for i in len(card_nodes):
		card_nodes[i].idle_pos = _get_card_position(i)
		card_nodes[i].hover_pos = Vector2(_get_card_position(i).x, card_origin.global_position.y - 50)
		if len(card_nodes) > 1:
			card_nodes[i].idle_rotation = max_rotation_degrees * rotation_curve.sample(float(i) / float(len(card_nodes) - 1))
		else:
			card_nodes[i].idle_rotation = 0
		card_nodes[i].return_to_idle_pos()
		card_nodes[i].default_z_index = i + 4

func _deal_hand():
	for i in range(cards_to_deal):
		_deal_card()
		await get_tree().create_timer(0.2).timeout

func _deal_card():
	if card_scene == null:
		return
	
	if len(draw_pile) == 0:
		draw_pile = discard_pile.duplicate()
		draw_pile.shuffle()
		discard_pile.clear()
		CardPilesChanged.emit(draw_pile.size(), discard_pile.size())
	
	var data: CardData = draw_pile.pop_front()
	
	if data == null:
		return
	
	var card: Card = card_scene.instantiate()
	add_child(card)
	card.global_position = card_spawn.global_position
	card.setup(data)
	card_nodes.append(card)
	CardPilesChanged.emit(draw_pile.size(), discard_pile.size())
	_rearrange_cards.call_deferred()

func add_card(card_data: CardData):
	if card_data == null:
		return
	
	var card: Card = card_scene.instantiate()
	add_child(card)
	card.global_position = card_spawn.global_position
	card.setup(card_data)
	card_nodes.append(card)
	CardPilesChanged.emit(draw_pile.size(), discard_pile.size())
	_rearrange_cards.call_deferred()

func _get_card_position(card_index: int) -> Vector2:
	var offset: float = x_offset
	if offset * (card_nodes.size() - 1) > max_hand_width:
		offset = max_hand_width / (card_nodes.size() - 1)
	var total_cards: float = len(card_nodes)
	var left_most_pos: float = ((-total_cards + 1) * offset) / 2
	var pos_x: float = left_most_pos + (float(card_index) * offset)
	
	var offset_y: float = y_offset * y_offset_curve.sample((1.0 / float(len(card_nodes))) * float(card_index))
	
	return card_origin.global_position + Vector2(pos_x, -offset_y)


func discard_card(card: Card):
	discard_pile.append(card.card_data)
	
	if card_nodes.has(card):
		card_nodes.erase.call_deferred(card)
	card.queue_free()
	CardPilesChanged.emit(draw_pile.size(), discard_pile.size())
	_rearrange_cards.call_deferred()

func _on_turn_start(character: Character):
	if GlobalData.current_room.type == RoomData.Type.REWARD or GlobalData.current_room.type == RoomData.Type.REST:
		return
		
	if character.character_data.is_player:
		_deal_hand()

func _on_turn_end(character: Character):
	if character.character_data.is_player:
		for card in card_nodes:
			discard_card(card)
