class_name CardInteractor
extends Node2D

signal CardCasted (card_data: CardData)

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

var selected_card: Card
var mouse_down_last_frame: bool
var mouse_down: bool

@export var drag_buffer_timer: Timer
var drag_buffer_threshold: float = 0.15
var cast_conditions_met: bool

func _enter_tree() -> void:
	ManagerRegistry.register("card_interactor", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("card_interactor")

func _process(_delta: float) -> void:
	if drag_buffer_timer == null:
		return
	
	var current_hover_card: Card = _get_selected_card()
	
	if Input.is_action_just_pressed("left_click") and current_hover_card != null:
		mouse_down = !mouse_down
		drag_buffer_timer.start(drag_buffer_threshold)
	
	
	if not mouse_down:
		if current_hover_card != null:
			if selected_card != null and current_hover_card != selected_card:
				selected_card.hover_exit()
				selected_card = null
			
			if selected_card != current_hover_card:
				selected_card = current_hover_card
				selected_card.hover_enter()
				
		elif selected_card != null:
			selected_card.hover_exit()
			selected_card = null
	
	if Input.is_action_just_released("left_click") and not drag_buffer_timer.time_left:
		mouse_down = false
	if mouse_down_last_frame and not mouse_down:
		_drop_card()
	elif not mouse_down_last_frame and mouse_down:
		_pickup_card()
	
	if Input.is_action_just_pressed("right_click"):
		_cancel_card()
	if get_global_mouse_position().y > card_manager.card_origin.global_position.y - 10:
		_cancel_card()
	
	mouse_down_last_frame = mouse_down

func _get_selected_card() -> Card:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	
	var intersections = space_state.intersect_point(query)
	
	var card_to_select: Card = null
	var card_z_index = -1
	
	for result in intersections:
		var collider: Node2D = result['collider']
		
		if collider is Card and collider.z_index > card_z_index:
			card_to_select = collider
			card_z_index = collider.z_index
	
	return card_to_select

func _pickup_card():
	if selected_card == null:
		return
	
	selected_card.drag_enter()

func _drop_card():
	if selected_card == null:
		return
	
	selected_card.drag_exit()
	
	cast_conditions_met = true
	
	if selected_card.global_position.y > global_position.y + 20:
		return
	
	if game_manager.current_energy < selected_card.card_data.cost:
		cast_conditions_met = false
	
	if game_manager.game_over:
		cast_conditions_met = false
	
	if not selected_card.card_data.check_cast_condition():
		cast_conditions_met = false
	
	if game_manager.player.defeated:
		cast_conditions_met = false
	
	if not cast_conditions_met:
		selected_card.flash_red()
		return
	
	CardCasted.emit(selected_card.card_data)
	game_manager.spend_energy(selected_card.card_data.cost)
	await selected_card.cast()
	card_manager.discard_card(selected_card)
	

func _cancel_card():
	if selected_card == null:
		return
	if selected_card.state != Card.States.DRAGGING:
		return
	
	selected_card.drag_exit()
	mouse_down = false
