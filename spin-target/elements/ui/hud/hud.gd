extends CanvasLayer


func _on_home_button_pressed() -> void:
		Events.location_changed.emit(Events.LOCATIONS.START)
