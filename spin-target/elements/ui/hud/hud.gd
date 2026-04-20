extends CanvasLayer

@onready var apples_label := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var knives_row := $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer
@onready var level_icons_row := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer
@onready var combo_label := $ComboLabel


func _ready() -> void:
	Events.apples_changed.connect(_on_apples_changed)
	Events.combo_changed.connect(_on_combo_changed)
	_on_apples_changed(Globals.apples)
	_hide_home_on_start()
	_update_knives_visual()
	_update_level_icons()
	_update_combo_display()


func _process(_delta: float) -> void:
	_update_knives_visual()
	_update_level_icons()


func _on_apples_changed(apples: int) -> void:
	if apples_label:
		apples_label.text = str(apples)


func _on_combo_changed(combo: int, multiplier: float) -> void:
	_update_combo_display()


func _update_combo_display() -> void:
	if not combo_label:
		return

	var current_scene := get_tree().current_scene
	var is_game := current_scene and current_scene.name == "Game"

	if not is_game or Globals.current_combo <= 0:
		combo_label.hide()
		return

	combo_label.show()
	combo_label.text = "COMBO x%d\n%.1fx" % [Globals.current_combo, Globals.combo_multiplier]

	# Анимация при увеличении комбо
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)


func _on_home_button_pressed() -> void:
	Events.location_changed.emit(Events.LOCATIONS.START)


func _hide_home_on_start() -> void:
	var home_button := $MarginContainer/VBoxContainer/HBoxContainer/HomeButton
	if home_button and get_tree().current_scene and get_tree().current_scene.name == "StartScreen":
		home_button.hide()


func _update_knives_visual() -> void:
	if not knives_row:
		return

	var current_scene := get_tree().current_scene
	var is_game := current_scene and current_scene.name == "Game"

	# визуальный счётчик ножей только в игре
	knives_row.get_parent().visible = is_game
	if not is_game:
		return

	var shooter := get_tree().get_first_node_in_group("knifeshooter")
	if not shooter:
		return
	var throws_left: int = shooter.get_throws_left()
	var icons := knives_row.get_children()
	var total := icons.size()

	for i in range(icons.size()):
		var icon = icons[i]
		# сверху вниз гасим — последние иконки соответствуют оставшимся ножам
		var from_bottom_index := total - 1 - i
		if from_bottom_index < throws_left:
			icon.modulate = Color(1, 1, 1, 1)
		else:
			icon.modulate = Color(1, 1, 1, 0.2)


func _update_level_icons() -> void:
	if not level_icons_row:
		return

	var current_scene := get_tree().current_scene
	var is_game := current_scene and current_scene.name == "Game"
	level_icons_row.visible = is_game
	if not is_game:
		return

	var icons := level_icons_row.get_children()
	var level_idx := Globals.current_level

	for i in range(icons.size()):
		var icon = icons[i]
		if i <= level_idx:
			icon.modulate = Color(1, 1, 1, 1)
		else:
			icon.modulate = Color(1, 1, 1, 0.3)
