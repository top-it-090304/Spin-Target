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

func _ready():
	rmg.randomize()
	_init_knives()
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


func can_spend_apples(cost: int) -> bool:
	return apples >= cost


func spend_apples(cost: int) -> bool:
	if not can_spend_apples(cost):
		return false
	apples -= cost
	Events.apples_changed.emit(apples)
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
	return random_index
