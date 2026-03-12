extends CanvasLayer

@onready var apples_label := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var knives_row := $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer


func _ready() -> void:
	Events.apples_changed.connect(_on_apples_changed)
	_on_apples_changed(Globals.apples)
	_hide_home_on_start()
	_update_knives_visual()


func _process(_delta: float) -> void:
	_update_knives_visual()


func _on_apples_changed(apples: int) -> void:
	if apples_label:
		apples_label.text = str(apples)


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

	# показываем визуальный счётчик только в игре
	knives_row.get_parent().visible = is_game
	if not is_game:
		return

	var shooter := get_tree().get_first_node_in_group("knifeshooter")
	if not shooter:
		return

	var throws_left: int = shooter.remaining_knives + 1
	var icons := knives_row.get_children()

	for i in range(icons.size()):
		var icon = icons[i]
		if i < throws_left:
			icon.modulate = Color(1, 1, 1, 1)
		else:
			icon.modulate = Color(1, 1, 1, 0.2)
