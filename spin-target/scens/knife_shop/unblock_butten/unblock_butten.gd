extends PanelContainer

@onready var cost_label := $HBoxContainer/VBoxContainer2/Label


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_unlock_random_knife()


func _try_unlock_random_knife() -> void:
	var cost := 0
	if cost_label:
		cost = int(cost_label.text)

	if not Globals.can_spend_apples(cost):
		return

	var unlocked_index := Globals.unlock_random_knife()
	if unlocked_index == -1:
		return

	Globals.spend_apples(cost)

