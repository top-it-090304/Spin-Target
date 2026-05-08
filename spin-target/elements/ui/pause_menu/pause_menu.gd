extends CanvasLayer


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	if visible:
		resume()
	else:
		pause()


func pause() -> void:
	get_tree().paused = true
	show()


func resume() -> void:
	get_tree().paused = false
	hide()


func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Globals.reset_combo()
	Events.location_changed.emit(Events.LOCATIONS.GAME)


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	Globals.reset_combo()
	Events.location_changed.emit(Events.LOCATIONS.START)
