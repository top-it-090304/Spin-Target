extends Control

@onready var music_slider := $MarginContainer/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider := $MarginContainer/VBoxContainer/SFXContainer/SFXSlider
@onready var music_label := $MarginContainer/VBoxContainer/MusicContainer/MusicLabel
@onready var sfx_label := $MarginContainer/VBoxContainer/SFXContainer/SFXLabel


func _ready() -> void:
	if music_slider:
		music_slider.value = Globals.music_volume
		_update_music_label(Globals.music_volume)
	if sfx_slider:
		sfx_slider.value = Globals.sfx_volume
		_update_sfx_label(Globals.sfx_volume)


func _on_music_slider_value_changed(value: float) -> void:
	Globals.set_music_volume(value)
	_update_music_label(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	Globals.set_sfx_volume(value)
	_update_sfx_label(value)


func _update_music_label(value: float) -> void:
	if music_label:
		music_label.text = "Music: %d%%" % int(value * 100)


func _update_sfx_label(value: float) -> void:
	if sfx_label:
		sfx_label.text = "SFX: %d%%" % int(value * 100)


func _on_back_button_pressed() -> void:
	Events.location_changed.emit(Events.LOCATIONS.START)
