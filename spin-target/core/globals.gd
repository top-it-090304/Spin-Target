extends Node

var location_to_scene := {
	Events.LOCATIONS.GAME: preload("res://scens/game/game.tscn"),
	Events.LOCATIONS.START: preload("res://scens/start_screen/start_screen.tscn"),
	Events.LOCATIONS.SHOP: preload("res://scens/knife_shop/knife_shop.tscn")
}

var rmg := RandomNumberGenerator.new()

var apples: int = 0
var unlocked_knives: Array = []
const KNIVES_COUNT := 9

const LEVEL_COUNT := 6
var current_level: int = 0
var current_knife_index: int = 0

func _ready():
	rmg.randomize()
	_load_progress()
	Events.location_changed.connect(handle_location_change)


func handle_location_change(location: Events.LOCATIONS) -> void:
	get_tree().change_scene_to_packed(location_to_scene.get(location))


func _init_knives() -> void:
	unlocked_knives.resize(KNIVES_COUNT)
	for i in range(KNIVES_COUNT):
		# Первый нож можно считать разблокированным по умолчанию
		unlocked_knives[i] = i == 0
	Events.knives_changed.emit()


func add_apples(amount: int) -> void:
	apples += amount
	if apples < 0:
		apples = 0
	Events.apples_changed.emit(apples)
	_save_progress()


func can_spend_apples(cost: int) -> bool:
	return apples >= cost


func spend_apples(cost: int) -> bool:
	if not can_spend_apples(cost):
		return false
	apples -= cost
	Events.apples_changed.emit(apples)
	_save_progress()
	return true


func is_knife_unlocked(index: int) -> bool:
	if index < 0 or index >= unlocked_knives.size():
		return false
	return unlocked_knives[index]


func unlock_random_knife() -> int:
	var locked_indices: Array[int] = []
	for i in range(unlocked_knives.size()):
		if not unlocked_knives[i]:
			locked_indices.append(i)

	if locked_indices.is_empty():
		return -1

	var random_array_index: int = rmg.randi_range(0, locked_indices.size() - 1)
	var random_index: int = locked_indices[random_array_index]
	unlocked_knives[random_index] = true
	Events.knives_changed.emit()
	_save_progress()
	return random_index


func go_to_next_level() -> void:
	current_level += 1
	if current_level >= LEVEL_COUNT:
		current_level = 0
	_save_progress()
	Events.location_changed.emit(Events.LOCATIONS.GAME)


func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "apples", apples)
	config.set_value("progress", "current_level", current_level)
	config.set_value("progress", "current_knife_index", current_knife_index)
	config.set_value("progress", "unlocked_knives", unlocked_knives)
	config.save("user://save.cfg")


func _load_progress() -> void:
	var config := ConfigFile.new()
	var err := config.load("user://save.cfg")
	if err != OK:
		_init_knives()
		return

	apples = int(config.get_value("progress", "apples", 0))
	current_level = int(config.get_value("progress", "current_level", 0))
	current_knife_index = int(config.get_value("progress", "current_knife_index", 0))
	unlocked_knives = config.get_value("progress", "unlocked_knives", [])

	if unlocked_knives.size() != KNIVES_COUNT:
		_init_knives()
	else:
		Events.apples_changed.emit(apples)
		Events.knives_changed.emit()
