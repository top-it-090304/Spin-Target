extends Node2D

var knife_scene := preload("res://elements/knife/knife.tscn")

const KNIVES_PER_LEVEL: int = 7
const LOSE_CHECK_GRACE_SECONDS := 0.45

@onready var knife := $Knife
@onready var timer := $Timer

var remaining_knives: int = 0
var game_over: bool = false
var lose_check_pending: bool = false


func get_throws_left() -> int:
	var in_hand := is_instance_valid(knife) and knife.get_parent() == self
	return (1 if in_hand else 0) + remaining_knives


func _ready() -> void:
	# уже есть один нож в сцене
	remaining_knives = KNIVES_PER_LEVEL - 1


func create_new_knife():
	if game_over:
		return
	knife = knife_scene.instantiate()
	add_child(knife)
	remaining_knives -= 1
	
func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	# бросок только если нож в руке (не на мишени)
	if not is_instance_valid(knife) or knife.get_parent() != self:
		return
	var throw_from_touch: bool = event is InputEventScreenTouch and event.is_pressed()
	var throw_from_mouse: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if (throw_from_touch or throw_from_mouse) and timer.time_left <= 0:
		Globals.register_throw()
		knife.throw()
		timer.start()


func _on_timer_timeout():
	if game_over:
		return
	if remaining_knives > 0:
		create_new_knife()
	else:
		_check_lose_condition_deferred()


func _check_lose_condition_deferred() -> void:
	if lose_check_pending:
		return
	lose_check_pending = true

	var elapsed := 0.0
	while elapsed < LOSE_CHECK_GRACE_SECONDS:
		await get_tree().physics_frame
		if game_over:
			lose_check_pending = false
			return
		var target := get_tree().get_first_node_in_group("target")
		if target and not target.has_apples_left():
			lose_check_pending = false
			return
		elapsed += get_physics_process_delta_time()

	var target := get_tree().get_first_node_in_group("target")
	if target and target.has_apples_left():
		game_over = true
		var overlay := get_tree().get_first_node_in_group("restart_overlay")
		if overlay:
			overlay.show_overlay()
	lose_check_pending = false
