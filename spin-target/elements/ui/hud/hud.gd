extends CanvasLayer

@onready var apples_label := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var knives_label := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer3/KnivesLabel


func _ready() -> void:
	Events.apples_changed.connect(_on_apples_changed)
	_on_apples_changed(Globals.apples)
	_update_knives_label()
	_hide_home_on_start()


func _on_apples_changed(apples: int) -> void:
	if apples_label:
		apples_label.text = str(apples)


func _on_home_button_pressed() -> void:
	Events.location_changed.emit(Events.LOCATIONS.START)


func _process(_delta: float) -> void:
	_update_knives_label()


func _update_knives_label() -> void:
	if knives_label and is_instance_valid(get_tree().get_first_node_in_group("target")):
		var shooter := get_tree().get_first_node_in_group("knifeshooter")
		if shooter:
			knives_label.text = str(shooter.remaining_knives + 1)


func _hide_home_on_start() -> void:
	var home_button := $MarginContainer/VBoxContainer/HBoxContainer/HomeButton
	if home_button and get_tree().current_scene and get_tree().current_scene.name == "StartScreen":
		home_button.hide()
