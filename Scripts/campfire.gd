extends CheckpointButton

@export var click_particles: GPUParticles2D
@export var campfire_click_sound: AudioStream

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")


func checkpoint_clicked():
	if click_particles:
		click_particles.restart()
	audio_manager.play(campfire_click_sound)
	await get_tree().create_timer(1).timeout
	game_manager._on_rest_button_pressed()

func _pre_warm_particles():
	click_particles.emitting = true
