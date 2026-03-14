extends Node2D

var knife_scene := preload("res://elements/knife/knife.tscn")

const KNIVES_PER_LEVEL: int = 7

@onready var knife := $Knife
@onready var timer := $Timer

var remaining_knives: int = 0
var game_over: bool = false


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
	if event is InputEventScreenTouch and event.is_pressed() and timer.time_left <= 0:
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
