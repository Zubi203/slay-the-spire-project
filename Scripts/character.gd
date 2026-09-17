class_name Character
extends Node2D

signal HealthUpdated
signal BlockUpdated
signal CharcterDefeated
signal DamageTaken (target: Character)

var current_health: int:
	set(value):
		
		var health_difference: int = value - current_health
		spawn_number_effect(health_difference)
		
		current_health =  clamp(value, 0, character_data.max_health)
		HealthUpdated.emit()
		if current_health <= 0:
			die()

var current_block: int:
	set(value):
		current_block = value
		if current_block < 0:
			current_block = 0
		BlockUpdated.emit()

@export var number_effect: PackedScene
@export var character_data: CharacterData
@export var attack_delay: float = 0.3
@export var highlight: Sprite2D = null
@export var glow_highlight: Sprite2D = null
var glow_target_alpha: float = 0.0
@onready var sprite: CharacterAnimation = %CharacterAnimation
@onready var status_icon_container: GridContainer = %StatusIconContainer

@export var card_detector: Area2D
@export var damage_sound: AudioStream
@export var blocked_damage_sound: AudioStream
@export var block_sound: AudioStream
@export var heal_sound: AudioStream
@export var attack_sound: AudioStream
@export var buff_sound: AudioStream
@export var debuff_sound: AudioStream

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var game_manager: GameManager:
	get: return ManagerRegistry.get_manager("game_manager")

var card_interactor: CardInteractor:
	get: return ManagerRegistry.get_manager("card_interactor")

var status_effects: Array[ActiveEffect] = []
@export var status_icon_scene: PackedScene
@export var debuff_particles: GPUParticles2D
@export var buff_particles: GPUParticles2D
@export var status_prompt_scene: PackedScene
@export var status_prompt_container: VBoxContainer


var defeated: bool = false


func _ready() -> void:
	_pre_warm_particles()
	if highlight:
		highlight.modulate.a = 0
	game_manager.TurnEnd.connect(on_turn_end)
	game_manager.TurnStart.connect(on_turn_start)

func _process(_delta: float) -> void:
	check_collisions()
	move_highlight_to_target_alpha(_delta)

func setup(data: CharacterData):
	if data == null:
		return
	character_data = data
	if sprite:
		sprite.play(sprite.IDLE_ANIM)
		sprite.idle_tween_animation()
		sprite.sprite_frames = character_data.animation_sprites
		sprite.flip_h = character_data.flip_sprite
		if not character_data.is_player:
			sprite.offset.x = -52 if character_data.flip_sprite else 52
		sprite.base_scale *= character_data.sprite_scale_multiplier
		sprite._set_base_attributes()
	current_health = character_data.max_health
	for child in get_children():
		if child is EnemyAI:
			child.setup_ai()
		if child is HealthBar:
			child.setup_ui()

func take_damage(amount: int):
	if current_health <= 0:
		return
	DamageTaken.emit(self)
	for status in status_effects:
		if status.status_data is ModifierStatus:
			amount = status.status_data.apply_modifier(self, amount, ModifierStatus.AffectedStat.INCOMING_DAMAGE)
	
	var damage_to_take: int = amount - current_block
	
	if current_block > 0:
		take_block_damage(clamp(amount, 0, current_block))
	
	if damage_to_take <= 0:
		return
	
	current_health -= damage_to_take
	
	audio_manager.play(damage_sound)
	if sprite:
		sprite.play(sprite.HIT_ANIM)
		sprite.damage_tween_animation(amount)

func take_block_damage(amount: int):
	current_block -= amount
	spawn_number_effect(amount, true)
	audio_manager.play(blocked_damage_sound)
	sprite._flash_effect(CharacterAnimation.FlashColors.BLUE)
	if sprite.block_damage_particles:
		sprite.block_damage_particles.restart()

func attack(target: Character, damage: int):
	if sprite:
		sprite.play(sprite.ATTACK_ANIM)
		if not character_data.is_player:
			sprite.attack_tween_animation()
	audio_manager.play(attack_sound)
	await get_tree().create_timer(attack_delay).timeout
	if target == null:
		return
	
	for status in status_effects:
		if status.status_data is ModifierStatus:
			damage = status.status_data.apply_modifier(self, damage, ModifierStatus.AffectedStat.ATTACK)
	
	target.take_damage(damage)

func heal(amount: int):
	
	for status in status_effects:
		if status.status_data is ModifierStatus:
			amount = status.status_data.apply_modifier(self, amount, ModifierStatus.AffectedStat.HEALING)
	
	current_health += amount
	audio_manager.play(heal_sound)
	if sprite:
		sprite.heal_tween_animation(amount)

func block(amount: int):
	
	for status in status_effects:
		if status.status_data is ModifierStatus:
			amount = status.status_data.apply_modifier(self, amount, ModifierStatus.AffectedStat.BLOCK)
	
	current_block += amount
	audio_manager.play(block_sound)
	if sprite:
		sprite.block_tween_animation()

func on_turn_end(character: Character):
	if character == self:
		
		for status in status_effects:
			status.status_data.on_turn_end(self)
			if status.status_data.expire_on == StatusEffect.ExpireOn.TURN_END:
				status.turns_remaining -= 1
				_update_status_icon_durations(status)
			await get_tree().create_timer(0.1).timeout
		
		remove_expired_statuses()
	
	else:
		
		for effect in status_effects:
			if effect.status_data is RetainBlockStatus:
				return
		
		current_block = 0

func on_turn_start(character: Character):
	if not character == self:
		return
	
	for status in status_effects:
		status.status_data.on_turn_start(self)
		if status.status_data.expire_on == StatusEffect.ExpireOn.TURN_START:
			status.turns_remaining -= 1
			_update_status_icon_durations(status)
		await get_tree().create_timer(0.1).timeout
	
	remove_expired_statuses()

	
func remove_expired_statuses():
	var statuses_to_remove: Array[ActiveEffect] = []
	for status in status_effects:
		if status.turns_remaining <= 0:
			statuses_to_remove.append(status)
		
	for status in statuses_to_remove:
		status.status_data.on_remove(self)
		status.status_data = null
		status_effects.erase(status)
		_update_status_icon_durations(status)
		await get_tree().create_timer(0.1).timeout

func die():
	CharcterDefeated.emit()
	defeated = true
	audio_manager.play_random_pitch(character_data.death_sound)
	if sprite:
		sprite.play(sprite.DEATH_ANIM)
		sprite.death_tween_animation()

func activate_highlight():
	if highlight == null:
		return
	var tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.5, 0.2).from(0.0)

func deactivate_higlight():
	if highlight == null:
		return
	var tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.2)

func add_status_front(status: StatusEffect):
	
	for effect in status_effects:
		if effect.status_data == status:
			if not status.stackable:
				effect.turns_remaining = status.base_duration
				_play_status_animation(status)
				_display_status_prompt(status)
				_play_status_sound(status)
				_update_status_icon_durations(effect)
				return
	
	
	var effect: ActiveEffect = ActiveEffect.new(status)
	status_effects.push_front(effect)
	_update_status_icons(effect)
	_play_status_animation(status)
	_display_status_prompt(status)
	_play_status_sound(status)
	_update_status_icon_durations(effect)

func add_status(status: StatusEffect):
	
	for effect in status_effects:
		if effect.status_data == status:
			if not status.stackable:
				effect.turns_remaining = status.base_duration
				_play_status_animation(status)
				_display_status_prompt(status)
				_play_status_sound(status)
				_update_status_icon_durations(effect)
				return
	
	var effect: ActiveEffect = ActiveEffect.new(status)
	status_effects.append(effect)
	_update_status_icons(effect)
	_play_status_animation(status)
	_display_status_prompt(status)
	_play_status_sound(status)
	_update_status_icon_durations(effect)

func _play_status_animation(status: StatusEffect):
	if status.buff_type == StatusEffect.Type.BUFF:
		if sprite:
			sprite._flash_effect(CharacterAnimation.FlashColors.YELLOW)
		if buff_particles:
			buff_particles.restart()
	if status.buff_type == StatusEffect.Type.DEBUFF:
		if sprite:
			sprite._flash_effect(CharacterAnimation.FlashColors.ORANGE)
		if debuff_particles:
			debuff_particles.restart()

func _display_status_prompt(status: StatusEffect):
	if status_prompt_scene == null:
		return
	var label: StatusTextEffect = status_prompt_scene.instantiate()
	if status_prompt_container:
		status_prompt_container.add_child(label)
	else:
		get_tree().current_scene.add_child(label)
	label.global_position = global_position + Vector2.UP * 30
	label.animate(status)

func _play_status_sound(status: StatusEffect):
	if status.buff_type == StatusEffect.Type.BUFF:
		audio_manager.play_random_pitch(buff_sound)
	if status.buff_type == StatusEffect.Type.DEBUFF:
		audio_manager.play_random_pitch(debuff_sound)


	

func _update_status_icons(effect: ActiveEffect):
	var effect_exists: bool = false
	for child in status_icon_container.get_children():
		if child is StatusIcon:
			if child.status_effect.status_data == effect.status_data:
				if not effect.status_data.stackable:
					continue
				child.count += 1
				child.setup(effect, self)
				effect_exists = true
	
	if effect_exists:
		return
	
	if status_icon_scene == null:
		return
	var icon: StatusIcon = status_icon_scene.instantiate()
	status_icon_container.add_child(icon)
	icon.setup(effect, self)

func _update_status_icon_durations(effect: ActiveEffect):
	for child in status_icon_container.get_children():
		if child is StatusIcon:
			if child.status_effect.status_data == effect.status_data:
				child.setup(effect, self)

#func _remove_status_icon(effect: ActiveEffect):
#	for child in status_icon_container.get_children():
#		if child is StatusIcon:
#			if child.status_data == effect.status_data:
#				child.count -= 1
#				if child.count <= 0:
#					child.remove()

func spawn_number_effect(num: int, is_blocked: bool = false):
	if number_effect == null:
		return
	var number: NumberEffect = number_effect.instantiate()
	number.global_position = global_position + Vector2(0, -20)
	get_tree().current_scene.add_child(number)
	number.animate(num, is_blocked)

func _pre_warm_particles():
	buff_particles.emitting = true
	debuff_particles.emitting = true

func check_collisions():
	if card_detector == null:
		return
	if glow_highlight == null:
		return
	
	for area in card_detector.get_overlapping_areas():
		if area is Card:
			if area.card_data.type == CardData.CardType.ATTACK and not character_data.is_player:
				glow_target_alpha = 0.8
				return
			elif area.card_data.type == CardData.CardType.SKILL and character_data.is_player:
				glow_target_alpha = 0.8
				return
	glow_target_alpha = 0.0

func move_highlight_to_target_alpha(delta: float):
	glow_highlight.modulate.a = lerpf(glow_highlight.modulate.a, glow_target_alpha, delta * 20)
