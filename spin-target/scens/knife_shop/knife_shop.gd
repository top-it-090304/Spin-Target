extends Control

@onready var preview := $MarginContainer/VBoxContainer/PreviewRow/PreviewPanel/MarginContainer/TextureRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var stats_label: Label = $MarginContainer/VBoxContainer/PreviewRow/DescriptionPanel/MarginContainer/VBoxContainer/StatsLabel


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
	var knife_data := Globals.get_current_knife_data()
	if name_label:
		name_label.text = String(knife_data.get("name", ""))
	if description_label:
		description_label.text = String(knife_data.get("description", ""))
	if stats_label:
		stats_label.text = "\n".join(Globals.get_knife_stat_lines(Globals.current_knife_index))
