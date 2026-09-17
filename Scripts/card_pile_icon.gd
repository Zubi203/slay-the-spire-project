
extends Control

enum CardIconType{
	DISCARD,
	DRAW,
	DECK
}
@export var type: CardIconType
@export var colors: Dictionary[CardIconType, Color] = {
	CardIconType.DISCARD: Color.DARK_RED,
	CardIconType.DRAW: Color.DARK_GREEN,
	CardIconType.DECK: Color.YELLOW
}

@export var card_panels: Array[Panel]
@export var style_box: StyleBoxFlat

func _ready() -> void:
	if style_box == null:
		return
	style_box.bg_color = colors[type]
	for card: Panel in card_panels:
		card.add_theme_stylebox_override("panel", style_box)
