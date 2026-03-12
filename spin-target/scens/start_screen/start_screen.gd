extends Control

@onready var preview := $MarginContainer/VBoxContainer/CenterContainer/TextureRect


func _ready() -> void:
	_update_preview()


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
