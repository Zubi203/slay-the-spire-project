extends TextureRect

@onready var character: Character = get_parent()
@export var block_text: Label = null
var prev_block_value: int = 0
var base_scale: Vector2
var base_position: Vector2

func _ready() -> void:
	character.BlockUpdated.connect(update_block_ui)
	base_scale = scale
	base_position = global_position
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

func update_block_ui():
	if character == null:
		return
	if block_text == null:
		return
	
	
	if prev_block_value <= 0 and character.current_block > 0:
		entry_animation()
	
	if prev_block_value > 0 and character.current_block <= 0:
		exit_animation()
	prev_block_value = character.current_block
	block_text.text = str(character.current_block)

func entry_animation():
	show()
	global_position = base_position
	modulate.a = 1
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", base_scale, 0.2).from(Vector2.ZERO)

func exit_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "position:y", base_position.y + 5, 0.3).from(base_position.y)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(0.3).timeout
	hide()
