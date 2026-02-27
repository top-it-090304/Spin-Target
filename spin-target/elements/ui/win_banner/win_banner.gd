extends Control


func _ready() -> void:
	hide()


func show_banner_and_next_level() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	hide()
	Globals.go_to_next_level()

