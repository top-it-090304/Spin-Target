extends CanvasLayer

@onready var label_level := $MarginContainer/Control/PanelContainer/VBoxContainer/Label
@onready var animation_player := $AnimationPlayer


func _ready() -> void:
	hide()
	if animation_player:
		animation_player.stop()
	_update_level_label()


func _update_level_label() -> void:
	if label_level:
		label_level.text = str(Globals.current_level + 1)


func show_overlay() -> void:
	_update_level_label()
	show()
	if animation_player:
		animation_player.play("show_overlay")


func _on_button_pressed() -> void:
	if animation_player:
		animation_player.stop()
	hide()
	Globals.reset_to_first_level()
	Events.location_changed.emit(Events.LOCATIONS.GAME)

