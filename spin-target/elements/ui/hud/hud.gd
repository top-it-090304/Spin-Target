extends CanvasLayer

@onready var apples_label := $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label


func _ready() -> void:
	Events.apples_changed.connect(_on_apples_changed)
	_on_apples_changed(Globals.apples)


func _on_apples_changed(apples: int) -> void:
	if apples_label:
		apples_label.text = str(apples)


func _on_home_button_pressed() -> void:
	Events.location_changed.emit(Events.LOCATIONS.START)
