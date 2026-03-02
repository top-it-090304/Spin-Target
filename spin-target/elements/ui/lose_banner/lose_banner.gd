extends Control


func _ready() -> void:
	hide()


func show_banner_and_restart_level() -> void:
	if not is_inside_tree():
		return
	show()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	hide()
	Globals.location_to_scene[Events.LOCATIONS.GAME] # touch to ensure autoload
	Events.location_changed.emit(Events.LOCATIONS.GAME)

