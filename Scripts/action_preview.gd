class_name ActionPreview
extends Button

@export var intent_panel: PanelContainer
@export var intent_label: RichTextLabel

var base_scale: Vector2
var panel_tween: Tween

var card_interactor: CardInteractor:
	get: return ManagerRegistry.get_manager("card_interactor")

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

func _ready() -> void:
	if intent_panel:
		base_scale = intent_panel.scale
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(card: CardData):
	if card == null:
		return
	if intent_label == null:
		return
	
	var data: CardData.CastData = CardData.CastData.new()
	if game_manager.player:
		data.opponent = game_manager.player
	if game_manager.enemy:
		data.caster = game_manager.enemy
	
	intent_label.text = "[b]Enemy Intent: [/b]" + card.get_description(data) 

func _on_mouse_entered() -> void:
	if card_interactor.selected_card != null:
		return
	if intent_panel == null:
		return
	
	intent_panel.pivot_offset.y = intent_panel.size.y / 2
	intent_panel.pivot_offset.x = intent_panel.size.x
	
	if panel_tween and panel_tween.is_running():
		panel_tween.kill()
	panel_tween = create_tween()
	intent_panel.show()
	panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	panel_tween.tween_property(intent_panel, "scale:x", base_scale.x, 0.08)
	panel_tween.parallel().tween_property(intent_panel, "scale:y", base_scale.y, 0.1)

func _on_mouse_exited() -> void:
	if intent_panel == null:
		return
	
	intent_panel.pivot_offset.y = intent_panel.size.y / 2
	intent_panel.pivot_offset.x = intent_panel.size.x
	
	if panel_tween and panel_tween.is_running():
		panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(intent_panel, "scale", Vector2.ZERO, 0.06)
	panel_tween.tween_callback(intent_panel.hide).set_delay(0.1)
