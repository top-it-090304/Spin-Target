extends Control

@onready var preview := $MarginContainer/VBoxContainer/TextureRect


func _ready() -> void:
	Events.knives_changed.connect(_on_knives_changed)
	_on_knives_changed()


func _on_knives_changed() -> void:
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

