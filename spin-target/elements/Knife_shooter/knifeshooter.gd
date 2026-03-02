extends Node2D

var knife_scene := preload("res://elements/knife/knife.tscn")

const KNIVES_PER_LEVEL := Target.APPLE_NUMBER_ON_TARGET + 1

@onready var knife := $Knife
@onready var timer := $Timer

var remaining_knives: int = 0


func _ready() -> void:
	# уже есть один нож в сцене
	remaining_knives = KNIVES_PER_LEVEL - 1


func create_new_knife():
	knife = knife_scene.instantiate()
	add_child(knife)
	remaining_knives -= 1
	
func _input(event: InputEvent):
	if event is InputEventScreenTouch and event.is_pressed() and timer.time_left <= 0:
		knife.throw()
		timer.start()


func _on_timer_timeout():
	if remaining_knives > 0:
		create_new_knife()
	else:
		_check_lose_condition()


func _check_lose_condition() -> void:
	var target := get_tree().get_first_node_in_group("target")
	if target and target.has_apples_left():
		var banner := get_tree().get_first_node_in_group("lose_banner")
		if banner:
			banner.call("show_banner_and_restart_level")
		else:
			Events.location_changed.emit(Events.LOCATIONS.GAME)
