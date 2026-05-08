extends Node2D

const CAMERA_SHAKE_DECAY := 26.0

@onready var camera: Camera2D = $Camera2D

var camera_shake_strength := 0.0
var camera_shake_time := 0.0
var camera_base_offset := Vector2.ZERO


func _ready() -> void:
	Music.set_music_for_level(Globals.current_level)
	Globals.start_level_run()
	Globals.reset_combo()
	if camera:
		camera_base_offset = camera.offset


func _process(delta: float) -> void:
	if not camera:
		return
	if camera_shake_time <= 0.0:
		camera.offset = camera_base_offset
		return
	camera_shake_time -= delta
	camera_shake_strength = max(camera_shake_strength - CAMERA_SHAKE_DECAY * delta, 0.0)
	camera.offset = camera_base_offset + Vector2(
		Globals.rmg.randf_range(-camera_shake_strength, camera_shake_strength),
		Globals.rmg.randf_range(-camera_shake_strength, camera_shake_strength)
	)


func shake_camera(strength: float = 7.0, duration: float = 0.12) -> void:
	camera_shake_strength = max(camera_shake_strength, strength)
	camera_shake_time = max(camera_shake_time, duration)
