class_name CameraController
extends Camera2D

var shake_intensity: float = 0

func _enter_tree() -> void:
	ManagerRegistry.register("camera_controller", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("camera_controller")

func shake (intensity: float):
	if not GlobalData.screen_shake_enabled:
		return
	
	shake_intensity = intensity

func _process(delta: float) -> void:
	if shake_intensity <= 0:
		return
	
	shake_intensity = move_toward(shake_intensity, 0.0, delta * shake_intensity * 5)
	offset.x = randf_range(-shake_intensity, shake_intensity)
	offset.y = randf_range(-shake_intensity, shake_intensity)
