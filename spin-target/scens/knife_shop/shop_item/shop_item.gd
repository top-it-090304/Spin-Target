extends PanelContainer

@export var index: int = 0

@onready var texture_rect := $MarginContainer/TextureRect


func _ready() -> void:
	if Events.knives_changed.is_connected(_on_knives_changed) == false:
		Events.knives_changed.connect(_on_knives_changed)
	_on_knives_changed()


func _on_knives_changed() -> void:
	if not texture_rect:
		return

	if Globals.is_knife_unlocked(index):
		var knife_index := index + 1
		var texture_path := "res://assets/knife%d.png" % knife_index
		var texture := load(texture_path)
		if texture:
			texture_rect.texture = texture
	else:
		var locked_texture := load("res://assets/locked.png")
		if locked_texture:
			texture_rect.texture = locked_texture
