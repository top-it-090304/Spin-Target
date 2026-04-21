extends Node

const ACTION_NAV_UP := "gp_nav_up"
const ACTION_NAV_DOWN := "gp_nav_down"
const ACTION_NAV_LEFT := "gp_nav_left"
const ACTION_NAV_RIGHT := "gp_nav_right"
const ACTION_SELECT := "gp_select_hud"
const ACTION_THROW := "gp_throw_knife"
const ACTION_BACK := "gp_back_menu"

var _interactive_nodes: Array[Control] = []
var _selected_index: int = -1
var _last_scene: Node = null
var _base_button_original_modulate: Dictionary = {}
var _base_button_original_scale: Dictionary = {}
var _shop_grid_nodes: Array[Control] = []
var _shop_home_button: Control = null
var _shop_unblock_button: Control = null
var _shop_last_column: int = 1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_input_actions()


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene != _last_scene:
		_clear_custom_selection_visuals(_interactive_nodes)
		_interactive_nodes.clear()
		_last_scene = scene
		_selected_index = -1

	_refresh_interactive_nodes()
	if _interactive_nodes.is_empty():
		_handle_back_action()
		return
	if _selected_index < 0 or _selected_index >= _interactive_nodes.size():
		_set_selected_index(0)

	_handle_navigation()
	_handle_select_action()
	_handle_back_action()


func _handle_navigation() -> void:
	var direction := Vector2.ZERO
	if Input.is_action_just_pressed(ACTION_NAV_UP):
		direction = Vector2.UP
	elif Input.is_action_just_pressed(ACTION_NAV_DOWN):
		direction = Vector2.DOWN
	elif Input.is_action_just_pressed(ACTION_NAV_LEFT):
		direction = Vector2.LEFT
	elif Input.is_action_just_pressed(ACTION_NAV_RIGHT):
		direction = Vector2.RIGHT

	if direction == Vector2.ZERO:
		return

	if _last_scene != null and _last_scene.name == "KnifeShop":
		var handled := _handle_shop_navigation(direction)
		if handled:
			return

	var next_index := _find_next_index_in_direction(direction)
	if next_index == -1:
		return
	_set_selected_index(next_index)


func _handle_select_action() -> void:
	if not Input.is_action_just_pressed(ACTION_SELECT):
		return
	if _selected_index < 0 or _selected_index >= _interactive_nodes.size():
		return

	var selected := _interactive_nodes[_selected_index]
	if selected == null:
		return

	if selected is BaseButton:
		selected.emit_signal("pressed")
		return

	if selected.has_method("gamepad_activate"):
		selected.call("gamepad_activate")


func _handle_back_action() -> void:
	if not Input.is_action_just_pressed(ACTION_BACK):
		return

	var scene := get_tree().current_scene
	if scene == null:
		return

	if scene.name == "KnifeShop":
		Events.location_changed.emit(Events.LOCATIONS.START)


func _refresh_interactive_nodes() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		_clear_custom_selection_visuals(_interactive_nodes)
		_interactive_nodes.clear()
		return

	if scene.name == "KnifeShop":
		_refresh_shop_interactive_nodes(scene)
		return

	var previous_selected: Control = null
	if _selected_index >= 0 and _selected_index < _interactive_nodes.size():
		previous_selected = _interactive_nodes[_selected_index]

	var collected: Array[Control] = []
	var controls: Array = scene.find_children("*", "Control", true, false)
	for node in controls:
		var control := node as Control
		if control == null:
			continue
		if not _is_interactive(control):
			continue
		collected.append(control)

	collected.sort_custom(func(a: Control, b: Control) -> bool:
		var ac := _get_center(a)
		var bc := _get_center(b)
		if absf(ac.y - bc.y) > 4.0:
			return ac.y < bc.y
		return ac.x < bc.x
	)

	var nodes_changed := not _same_nodes(_interactive_nodes, collected)
	if nodes_changed:
		_clear_custom_selection_visuals(_interactive_nodes)
	_interactive_nodes = collected

	if _interactive_nodes.is_empty():
		_selected_index = -1
		return

	if previous_selected != null:
		var preserved := _interactive_nodes.find(previous_selected)
		if preserved != -1:
			_set_selected_index(preserved)
			return

	if _selected_index == -1 or nodes_changed:
		_set_selected_index(0)


func _refresh_shop_interactive_nodes(scene: Node) -> void:
	var previous_selected: Control = null
	if _selected_index >= 0 and _selected_index < _interactive_nodes.size():
		previous_selected = _interactive_nodes[_selected_index]

	_shop_grid_nodes.clear()
	_shop_home_button = scene.get_node_or_null("HUD/MarginContainer/VBoxContainer/HBoxContainer/HomeButton")
	_shop_unblock_button = scene.get_node_or_null("MarginContainer/VBoxContainer/UnblockButten")
	var grid := scene.get_node_or_null("MarginContainer/VBoxContainer/GridContainer")
	if grid != null:
		for child in grid.get_children():
			var control := child as Control
			if control and _is_interactive(control):
				_shop_grid_nodes.append(control)

	var collected: Array[Control] = []
	if _shop_home_button and _is_interactive(_shop_home_button):
		collected.append(_shop_home_button)
	for node in _shop_grid_nodes:
		collected.append(node)
	if _shop_unblock_button and _is_interactive(_shop_unblock_button):
		collected.append(_shop_unblock_button)

	var nodes_changed := not _same_nodes(_interactive_nodes, collected)
	if nodes_changed:
		_clear_custom_selection_visuals(_interactive_nodes)
	_interactive_nodes = collected

	if _interactive_nodes.is_empty():
		_selected_index = -1
		return

	if previous_selected != null:
		var preserved := _interactive_nodes.find(previous_selected)
		if preserved != -1:
			_set_selected_index(preserved)
			return

	if _selected_index == -1 or nodes_changed:
		# В магазине стартовое выделение — первый нож, а не кнопка HOME.
		if _shop_grid_nodes.size() > 0:
			_set_selected_index(1)
			_shop_last_column = 0
		else:
			_set_selected_index(0)


func _clear_custom_selection_visuals(nodes: Array[Control]) -> void:
	for node in nodes:
		if not is_instance_valid(node) or not node.is_inside_tree():
			continue
		if node.has_method("set_gamepad_selected"):
			node.call("set_gamepad_selected", false)
		elif node is BaseButton:
			_apply_base_button_selection(node, false)


func _set_selected_index(value: int) -> void:
	if _interactive_nodes.is_empty():
		_selected_index = -1
		return

	value = clampi(value, 0, _interactive_nodes.size() - 1)
	if value == _selected_index:
		_apply_selection_visuals()
		return

	_selected_index = value
	_apply_selection_visuals()


func _apply_selection_visuals() -> void:
	for i in range(_interactive_nodes.size()):
		var node := _interactive_nodes[i]
		if not is_instance_valid(node) or not node.is_inside_tree():
			continue
		var selected := i == _selected_index
		if node.has_method("set_gamepad_selected"):
			node.call("set_gamepad_selected", selected)
			continue
		if node is BaseButton:
			_apply_base_button_selection(node, selected)


func _find_next_index_in_direction(direction: Vector2) -> int:
	if _selected_index < 0 or _selected_index >= _interactive_nodes.size():
		return -1

	var current := _interactive_nodes[_selected_index]
	if current == null:
		return -1

	var current_center := _get_center(current)
	var best_index := -1
	var best_score := INF

	for i in range(_interactive_nodes.size()):
		if i == _selected_index:
			continue
		var candidate := _interactive_nodes[i]
		if candidate == null:
			continue

		var delta := _get_center(candidate) - current_center
		var primary := _primary_axis_distance(direction, delta)
		if primary <= 0.0:
			continue
		var secondary := _secondary_axis_distance(direction, delta)
		var score := primary * 10000.0 + secondary * 50.0 + delta.length()
		if score < best_score:
			best_score = score
			best_index = i

	return best_index


func _primary_axis_distance(direction: Vector2, delta: Vector2) -> float:
	if direction == Vector2.UP:
		return -delta.y
	if direction == Vector2.DOWN:
		return delta.y
	if direction == Vector2.LEFT:
		return -delta.x
	return delta.x


func _secondary_axis_distance(direction: Vector2, delta: Vector2) -> float:
	if direction == Vector2.UP or direction == Vector2.DOWN:
		return absf(delta.x)
	return absf(delta.y)


func _get_center(control: Control) -> Vector2:
	return control.get_global_rect().get_center()


func _is_interactive(control: Control) -> bool:
	if not is_instance_valid(control):
		return false
	if not control.is_visible_in_tree():
		return false
	if control is BaseButton:
		return not control.disabled
	return control.has_method("gamepad_activate")


func _handle_shop_navigation(direction: Vector2) -> bool:
	if _interactive_nodes.is_empty() or _selected_index < 0 or _selected_index >= _interactive_nodes.size():
		return false

	var current := _interactive_nodes[_selected_index]
	if current == null:
		return false

	var columns: int = 3
	var grid_count: int = _shop_grid_nodes.size()

	if current == _shop_home_button:
		if direction == Vector2.DOWN and grid_count > 0:
			var to_index: int = mini(_shop_last_column, columns - 1)
			to_index = min(to_index, grid_count - 1)
			_set_selected_index(1 + to_index)
			return true
		return false

	if current == _shop_unblock_button:
		if direction == Vector2.UP and grid_count > 0:
			var row: int = int(ceil(float(grid_count) / float(columns))) - 1
			var col: int = clampi(_shop_last_column, 0, columns - 1)
			var target: int = mini(row * columns + col, grid_count - 1)
			_set_selected_index(1 + target)
			return true
		return false

	var grid_pos: int = _shop_grid_nodes.find(current)
	if grid_pos == -1:
		return false

	var row: int = grid_pos / columns
	var col: int = grid_pos % columns
	var target_grid_pos: int = grid_pos

	if direction == Vector2.LEFT:
		if col == 0:
			return false
		target_grid_pos = grid_pos - 1
	elif direction == Vector2.RIGHT:
		if col == columns - 1 or grid_pos + 1 >= grid_count:
			return false
		target_grid_pos = grid_pos + 1
	elif direction == Vector2.UP:
		if row == 0:
			if _shop_home_button != null:
				_shop_last_column = col
				_set_selected_index(_interactive_nodes.find(_shop_home_button))
				return true
			return false
		target_grid_pos = grid_pos - columns
	elif direction == Vector2.DOWN:
		var next_row_pos: int = grid_pos + columns
		if next_row_pos >= grid_count:
			if _shop_unblock_button != null:
				_shop_last_column = col
				_set_selected_index(_interactive_nodes.find(_shop_unblock_button))
				return true
			return false
		target_grid_pos = next_row_pos
	else:
		return false

	_shop_last_column = target_grid_pos % columns
	_set_selected_index(1 + target_grid_pos)
	return true


func _same_nodes(left: Array[Control], right: Array[Control]) -> bool:
	if left.size() != right.size():
		return false
	for i in range(left.size()):
		if left[i] != right[i]:
			return false
	return true


func _ensure_input_actions() -> void:
	_bind_joy_action(ACTION_NAV_UP, JOY_BUTTON_DPAD_UP)
	_bind_joy_action(ACTION_NAV_DOWN, JOY_BUTTON_DPAD_DOWN)
	_bind_joy_action(ACTION_NAV_LEFT, JOY_BUTTON_DPAD_LEFT)
	_bind_joy_action(ACTION_NAV_RIGHT, JOY_BUTTON_DPAD_RIGHT)
	_bind_axis_action(ACTION_NAV_UP, JOY_AXIS_LEFT_Y, -1.0)
	_bind_axis_action(ACTION_NAV_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_bind_axis_action(ACTION_NAV_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_bind_axis_action(ACTION_NAV_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_bind_joy_action(ACTION_SELECT, JOY_BUTTON_A)
	_bind_joy_action(ACTION_THROW, JOY_BUTTON_X)
	_bind_joy_action(ACTION_BACK, JOY_BUTTON_B)


func _bind_joy_action(action_name: String, joy_button: JoyButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var events := InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventJoypadButton and event.button_index == joy_button:
			return

	var button_event := InputEventJoypadButton.new()
	button_event.button_index = joy_button
	InputMap.action_add_event(action_name, button_event)


func _bind_axis_action(action_name: String, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var events := InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return

	var motion_event := InputEventJoypadMotion.new()
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	InputMap.action_add_event(action_name, motion_event)


func _apply_base_button_selection(button: BaseButton, selected: bool) -> void:
	var key := button.get_instance_id()
	if not _base_button_original_modulate.has(key):
		_base_button_original_modulate[key] = button.modulate
	if not _base_button_original_scale.has(key):
		_base_button_original_scale[key] = button.scale

	if selected:
		button.modulate = Color(1.0, 0.94, 0.7, 1.0)
		button.scale = Vector2(1.04, 1.04)
		if button.focus_mode == Control.FOCUS_NONE:
			button.focus_mode = Control.FOCUS_ALL
		button.grab_focus()
	else:
		button.modulate = _base_button_original_modulate[key]
		button.scale = _base_button_original_scale[key]
