class_name CharacterAnimation
extends AnimatedSprite2D

const IDLE_ANIM: String = "idle"
const ATTACK_ANIM: String = "attack"
const HIT_ANIM: String = "hit"
const DEATH_ANIM: String = "death"

enum FlashColors{
	RED,
	BLUE,
	GREEN,
	YELLOW,
	ORANGE
}

@export var animation_duration: float = 0.5
@export var shake_magnitude: float = 2

@export var heal_particles: GPUParticles2D
@export var block_particles: GPUParticles2D
@export var damage_particles: GPUParticles2D
@export var block_damage_particles: GPUParticles2D


@export var status_text_animation: PackedScene
@export var damage_text_animation: PackedScene

@export var crit_sfx: AudioStream

var base_scale: Vector2
var base_offset: Vector2
var idle_bob: bool = false

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func _ready() -> void:
	_pre_warm_particles()
	_set_base_attributes.call_deferred()

func _set_base_attributes():
	base_offset = offset
	base_scale = scale

func _on_animation_finished() -> void:
	if animation == IDLE_ANIM:
		return
	if animation == DEATH_ANIM:
		return
	
	play(IDLE_ANIM)
	idle_tween_animation()

func damage_tween_animation(amount: int):
	if amount <= 0:
		return
	
	_reset_idle_tween()
	
	_flash_effect(FlashColors.RED)
	if damage_particles:
		damage_particles.amount = int(clamp(float(damage_particles.amount + amount) / 2.0, 0, 30))
		damage_particles.restart()

	var multiplier: float = 1.0 + 2.0 * float(amount) / 10.0
	var tween = get_tree().create_tween()
	var shake_amount = clamp(shake_magnitude * multiplier, 0, shake_magnitude * 3)
	tween.set_loops(3)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "offset:x", base_offset.x + shake_amount, 0.02)
	tween.tween_property(self, "offset:x", base_offset.x - shake_amount, 0.04)
	tween.tween_property(self, "offset:x", base_offset.x, 0.02)
	
	var hitstop_duration: float = 0.0
	
	var screen_shake_intensity: float = 2
	if amount > 5 and amount <= 15:
		screen_shake_intensity += 2
	if amount > 15 and amount <= 30:
		screen_shake_intensity += 3
	if amount > 30 and amount <= 50:
		# extra particle effects
		hitstop_duration += 0.02
		screen_shake_intensity += 4
	if amount > 50:
		if crit_sfx:
			audio_manager.play(crit_sfx)
		hitstop_duration += 0.03
		# big slash vfx
		screen_shake_intensity += 4
	
	hitstop(hitstop_duration)
	ManagerRegistry.get_manager("camera_controller").shake(screen_shake_intensity)
	tween.tween_callback(idle_tween_animation)

func heal_tween_animation(amount: int):
	if amount <= 0:
		return
	_flash_effect(FlashColors.GREEN)
	if heal_particles:
		heal_particles.amount = int(clamp(float(heal_particles.amount + amount) / 2, 0, 30))
		heal_particles.restart()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	tween.tween_property(self, "scale:y", base_scale.y - 0.1, animation_duration * 0.1)
	tween.tween_property(self, "scale:x", base_scale.x + 0.1, animation_duration * 0.1)
	tween.set_parallel(false)
	tween.tween_interval(animation_duration * 0.2)
	tween.set_parallel(true)
	tween.tween_property(self, "scale:y", base_scale.y + 0.1, animation_duration * 0.3)
	tween.tween_property(self, "scale:x", base_scale.x - 0.1, animation_duration * 0.3)
	tween.set_parallel(false)
	tween.tween_interval(animation_duration * 0.3)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:y", base_scale.y, animation_duration * 0.4)
	tween.tween_property(self, "scale:x", base_scale.x, animation_duration * 0.4)
	tween.tween_callback(idle_tween_animation)

func idle_tween_animation():
	idle_bob = true

func _process(_delta: float) -> void:
	if idle_bob:
		var time = Time.get_unix_time_from_system()
		var scale_offset = sin(time * 4) * 0.001
		scale.y = scale.y + scale_offset

func _reset_idle_tween():
	idle_bob = false
	scale = base_scale

func death_tween_animation():
	_reset_idle_tween()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(self, "scale:x", base_scale.x + 0.2, animation_duration * 2)
	tween.tween_property(self, "scale:y", 0, animation_duration * 2)
	tween.tween_property(self, "modulate:a" , 0, animation_duration * 2)
	tween.tween_callback(owner.queue_free).set_delay(animation_duration * 2)

func block_tween_animation():
	if block_particles:
		block_particles.restart()
	_flash_effect(FlashColors.BLUE)

func attack_tween_animation():
	_reset_idle_tween()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset:x", base_offset.x + 10, animation_duration * 0.1)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "offset:x", base_offset.x - 70, animation_duration * 0.3)
	tween.tween_property(self, "offset:x", base_offset.x, animation_duration * 0.2)
	tween.tween_callback(idle_tween_animation)

func _flash_effect(color: FlashColors):
	var color_tween = create_tween()
	match color:
		FlashColors.BLUE:
			color_tween.tween_property(self, "material:shader_parameter/progress_blue", 1.0, animation_duration * 0.2)
			color_tween.tween_property(self, "material:shader_parameter/progress_blue", 0.0, animation_duration * 0.8)
		FlashColors.RED:
			color_tween.tween_property(self, "material:shader_parameter/progress_red", 1.0, animation_duration * 0.2)
			color_tween.tween_property(self, "material:shader_parameter/progress_red", 0.0, animation_duration * 0.8)
		FlashColors.GREEN:
			color_tween.tween_property(self, "material:shader_parameter/progress_green", 1.0, animation_duration * 0.2)
			color_tween.tween_property(self, "material:shader_parameter/progress_green", 0.0, animation_duration * 0.8)
		FlashColors.YELLOW:
			color_tween.tween_property(self, "material:shader_parameter/progress_yellow", 1.0, animation_duration * 0.2)
			color_tween.tween_property(self, "material:shader_parameter/progress_yellow", 0.0, animation_duration * 0.8)
		FlashColors.ORANGE:
			color_tween.tween_property(self, "material:shader_parameter/progress_orange", 1.0, animation_duration * 0.2)
			color_tween.tween_property(self, "material:shader_parameter/progress_orange", 0.0, animation_duration * 0.8)

func hitstop(duration: float = 0.05):
	await get_tree().create_timer(0.1).timeout
	if Engine.time_scale == 0.0:
		return
	
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func _pre_warm_particles():
	block_damage_particles.emitting = true
	block_particles.emitting = true
	damage_particles.emitting = true
	heal_particles.emitting = true
