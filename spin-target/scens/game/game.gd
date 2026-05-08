extends Node2D


func _ready() -> void:
	Music.set_music_for_level(Globals.current_level)
	# Сбрасываем комбо при начале уровня
	Globals.reset_combo()

