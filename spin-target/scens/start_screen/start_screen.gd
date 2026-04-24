extends Control

@onready var preview := $MarginContainer/VBoxContainer/CenterContainer/TextureRect
@onready var settings_overlay: Control = $SettingsOverlay
@onready var music_slider: HSlider = $SettingsOverlay/CenterRoot/PanelWrap/SettingsPanel/InnerMargin/SettingsVBox/MusicRow/MusicSlider
@onready var music_percent_label: Label = $SettingsOverlay/CenterRoot/PanelWrap/SettingsPanel/InnerMargin/SettingsVBox/MusicRow/MusicPercentLabel
@onready var reset_modal_layer: Control = $SettingsOverlay/ResetModalLayer
@onready var reset_cancel_button: Button = $SettingsOverlay/ResetModalLayer/ResetCenter/ResetPanelWrap/ResetPanel/ResetInner/ResetVBox/ResetCancelButton
@onready var reset_confirm_button: Button = $SettingsOverlay/ResetModalLayer/ResetCenter/ResetPanelWrap/ResetPanel/ResetInner/ResetVBox/ResetConfirmButton

@onready var exit_confirm_layer: Control = $ExitConfirmLayer
@onready var exit_stay_button: Button = $ExitConfirmLayer/ExitCenter/ExitPanelWrap/ExitPanel/ExitInner/ExitVBox/ExitStayButton
@onready var exit_quit_button: Button = $ExitConfirmLayer/ExitCenter/ExitPanelWrap/ExitPanel/ExitInner/ExitVBox/ExitQuitButton

@onready var play_button: Button = $MarginContainer/VBoxContainer/CenterContainer2/Button
@onready var settings_open_button: Button = $MarginContainer/VBoxContainer/CenterContainerSettings/SettingsButton
@onready var shop_button: TextureButton = $MarginContainer/VBoxContainer/CenterContainer3/TextureButton
@onready var exit_button: Button = $HUD/MarginContainer/VBoxContainer/TopBar/HomeButton

@onready var reset_progress_button: Button = $SettingsOverlay/CenterRoot/PanelWrap/SettingsPanel/InnerMargin/SettingsVBox/ResetProgressButton
@onready var close_button: Button = $SettingsOverlay/CenterRoot/PanelWrap/SettingsPanel/InnerMargin/SettingsVBox/CloseButton


func _ready() -> void:
	_update_preview()
	_sync_music_slider_from_music()
	if reset_modal_layer:
		reset_modal_layer.hide()
	if exit_confirm_layer:
		exit_confirm_layer.hide()


func open_exit_confirmation() -> void:
	if not exit_confirm_layer or exit_confirm_layer.visible:
		return
	exit_confirm_layer.show()
	_set_main_menu_blocked(true)
	if exit_stay_button:
		exit_stay_button.grab_focus()


func get_gamepad_overlay_chain() -> Array:
	if exit_confirm_layer.visible:
		return [exit_stay_button, exit_quit_button]
	if not settings_overlay.visible:
		return []
	if reset_modal_layer.visible:
		return [reset_cancel_button, reset_confirm_button]
	return [music_slider, reset_progress_button, close_button]


func gamepad_consume_back() -> bool:
	if exit_confirm_layer.visible:
		_close_exit_modal()
		return true
	if not settings_overlay.visible:
		return false
	if reset_modal_layer.visible:
		_close_reset_modal()
	else:
		_close_settings()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if exit_confirm_layer.visible:
		get_viewport().set_input_as_handled()
		_close_exit_modal()
		return
	if not settings_overlay.visible:
		return
	get_viewport().set_input_as_handled()
	if reset_modal_layer.visible:
		_close_reset_modal()
	else:
		_close_settings()


func _sync_music_slider_from_music() -> void:
	if not music_slider:
		return
	music_slider.set_value_no_signal(float(Music.get_music_volume_percent()))
	_update_music_percent_label(int(music_slider.value))


func _update_music_percent_label(percent: int) -> void:
	if music_percent_label:
		music_percent_label.text = "%d%%" % percent


func _set_main_menu_blocked(blocked: bool) -> void:
	var d := blocked
	if play_button:
		play_button.disabled = d
	if settings_open_button:
		settings_open_button.disabled = d
	if shop_button:
		shop_button.disabled = d
	if exit_button:
		exit_button.disabled = d


func _close_exit_modal() -> void:
	if exit_confirm_layer:
		exit_confirm_layer.hide()
	_set_main_menu_blocked(false)


func _on_exit_stay_pressed() -> void:
	_close_exit_modal()


func _on_exit_quit_pressed() -> void:
	_close_exit_modal()
	get_tree().quit()


func _on_exit_modal_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_exit_modal()


func _on_settings_button_pressed() -> void:
	if not settings_overlay:
		return
	settings_overlay.show()
	_set_main_menu_blocked(true)
	_sync_music_slider_from_music()
	if music_slider:
		music_slider.grab_focus()


func _on_settings_close_pressed() -> void:
	_close_settings()


func _close_settings() -> void:
	if reset_modal_layer and reset_modal_layer.visible:
		_close_reset_modal()
	if settings_overlay:
		settings_overlay.hide()
	_set_main_menu_blocked(false)


func _on_settings_dimmer_gui_input(event: InputEvent) -> void:
	if reset_modal_layer and reset_modal_layer.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_settings()


func _open_reset_modal() -> void:
	if reset_modal_layer:
		reset_modal_layer.show()
	if reset_cancel_button:
		reset_cancel_button.grab_focus()


func _close_reset_modal() -> void:
	if reset_modal_layer:
		reset_modal_layer.hide()


func _on_reset_modal_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_reset_modal()


func _on_reset_modal_cancel_pressed() -> void:
	_close_reset_modal()


func _on_reset_modal_confirm_pressed() -> void:
	Globals.reset_full_progress()
	_update_preview()
	_close_reset_modal()
	_close_settings()


func _on_music_slider_value_changed(value: float) -> void:
	Music.set_music_volume_linear(value / 100.0)
	_update_music_percent_label(int(round(value)))


func _on_reset_progress_pressed() -> void:
	_open_reset_modal()


func _update_preview() -> void:
	if not preview:
		return
	var knife_index := Globals.current_knife_index + 1
	if knife_index < 1:
		knife_index = 1
	if knife_index > 9:
		knife_index = 9
	var texture_path := "res://assets/knife%d.png" % knife_index
	var texture := load(texture_path)
	if texture:
		preview.texture = texture


func _on_button_pressed() -> void:
	Globals.current_level = 0
	Globals._save_progress()
	Events.location_changed.emit(Events.LOCATIONS.GAME)


func _on_texture_button_pressed() -> void:
	Events.location_changed.emit(Events.LOCATIONS.SHOP)
