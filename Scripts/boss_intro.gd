class_name BossIntro
extends ColorRect

@export var animation_player: AnimationPlayer
@export var impact_sound: AudioStream
signal IntroComplete

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var camera_controller: CameraController:
	get: return ManagerRegistry.get_manager("camera_controller")

func screen_shake():
	camera_controller.shake(3)

func end_transition():
	hide()
	IntroComplete.emit()

func play_boss_soundtrack():
	MusicManager.change_soundtrack(MusicManager.MusicTracks.BOSS)


func _on_visibility_changed() -> void:
	if visible:
		if animation_player:
			animation_player.play("boss_intro")

func _play_impact_sound():
	audio_manager.play(impact_sound)
