extends CheckpointButton

@export var open_sprite: Texture2D
@export var open_particles: GPUParticles2D
@export var chest_open_sound: AudioStream
@export var chest_sparkle_sound: AudioStream

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func checkpoint_clicked():
	if open_sprite:
		sprite.texture = open_sprite
	if open_particles:
		open_particles.restart()
	audio_manager.play(chest_open_sound)
	await get_tree().create_timer(0.1).timeout
	audio_manager.play(chest_sparkle_sound)
	await get_tree().create_timer(1).timeout
	game_manager._on_reward_button_pressed()

func _pre_warm_particles():
	open_particles.emitting = true
