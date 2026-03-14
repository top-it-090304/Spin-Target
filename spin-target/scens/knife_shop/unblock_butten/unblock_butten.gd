extends PanelContainer

@onready var cost_label := $HBoxContainer/VBoxContainer2/Label


func _ready() -> void:
	Events.knives_changed.connect(_update_cost)
	_update_cost()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_unlock_random_knife()


func _try_unlock_random_knife() -> void:
	var cost := 0
	if cost_label:
		cost = Globals.get_unlock_cost()

	if not Globals.can_spend_apples(cost):
		return

	var unlocked_index := Globals.unlock_random_knife()
	if unlocked_index == -1:
		return

	Globals.spend_apples(cost)

	_update_cost()


func _update_cost() -> void:
	if not cost_label:
		return
	var cost := Globals.get_unlock_cost()
	cost_label.text = str(cost)

