extends PanelContainer

@export var index: int = 0

@onready var texture_rect := $MarginContainer/TextureRect
var _is_gamepad_selected: bool = false


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
		# выделяем выбранный нож рамкой
		if Globals.current_knife_index == index:
			modulate = Color(1, 1, 1, 1)
		else:
			modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		var locked_texture := load("res://assets/locked.png")
		if locked_texture:
			texture_rect.texture = locked_texture
		modulate = Color(1, 1, 1, 1)

	if _is_gamepad_selected:
		modulate = modulate * Color(1.0, 0.92, 0.65, 1.0)
		scale = Vector2(1.06, 1.06)
	else:
		scale = Vector2.ONE


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		gamepad_activate()


func gamepad_activate() -> void:
	if not Globals.is_knife_unlocked(index):
		return
	Globals.current_knife_index = index
	Globals._save_progress()
	Events.knives_changed.emit()


func set_gamepad_selected(selected: bool) -> void:
	_is_gamepad_selected = selected
	_on_knives_changed()
