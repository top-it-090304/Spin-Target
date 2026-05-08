extends Node2D

var knife_scene := preload("res://elements/knife/knife.tscn")

const KNIVES_PER_LEVEL: int = 7

@onready var knife := $Knife
@onready var timer := $Timer

var remaining_knives: int = 0
var game_over: bool = false
const GAMEPAD_THROW_ACTION := "gp_throw_knife"


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

	# Поддержка тач-экрана, мыши и геймпада
	var throw_from_touch := event is InputEventScreenTouch and event.is_pressed()
	var throw_from_mouse := event.is_action_pressed("throw_knife")
	var throw_from_gamepad := event.is_action_pressed(GAMEPAD_THROW_ACTION)

	if (throw_from_touch or throw_from_mouse or throw_from_gamepad) and timer.time_left <= 0:
		knife.throw()
		timer.start()


func _on_timer_timeout():
	if game_over:
		return
	if remaining_knives > 0:
		create_new_knife()
	else:
		_check_lose_condition()


func _check_lose_condition() -> void:
	game_over = true
	var target := get_tree().get_first_node_in_group("target")
	if target and target.has_apples_left():
		var overlay := get_tree().get_first_node_in_group("restart_overlay")
		if overlay:
			overlay.show_overlay()
