class_name CharacterData
extends Resource

@export var name: String = ""
@export var max_health: int = 20
@export var is_player: bool = false
@export var flip_sprite: bool = false
@export var animation_sprites: SpriteFrames
@export var sprite_scale_multiplier: float = 1.0
@export var base_deck: Array[CardData] = []
@export var death_sound: AudioStream = null

@export var display_entry_text: bool = false
@export var entry_text: String = ""
