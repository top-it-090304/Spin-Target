extends Node

var location_to_scene = {
	Events.LOCATIONS.GAME: preload("res://scens/game/game.tscn"),
	Events.LOCATIONS.START: preload("res://scens/start_screen/start_screen.tscn"),
	Events.LOCATIONS.SHOP: preload("res://scens/knife_shop/knife_shop.tscn")
}

var rmg := RandomNumberGenerator.new()

var apples: int = 0
var unlocked_knives: Array = []
const KNIVES_COUNT = 9
const DEFAULT_KNIFE_DATA := {
	"name": "Обычный",
	"description": "Надёжный стартовый нож.",
	"speed_multiplier": 1.0,
	"hit_width_multiplier": 1.0,
	"apple_reward_multiplier": 1.0,
	"golden_reward_multiplier": 1.0,
	"sharp_hit_multiplier": 1.0,
	"hit_feedback_multiplier": 1.0
}
const KNIFE_DATA := [
	{
		"name": "Обычный",
		"description": "Надёжный стартовый нож.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.0,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.0
	},
	{
		"name": "Быстрый",
		"description": "Быстро летит к мишени.",
		"speed_multiplier": 1.22,
		"hit_width_multiplier": 0.88,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 0.95
	},
	{
		"name": "Широкий",
		"description": "Проще задевает яблоки.",
		"speed_multiplier": 0.9,
		"hit_width_multiplier": 1.28,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.08
	},
	{
		"name": "Садовый",
		"description": "Даёт больше яблок за сбор.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.0,
		"apple_reward_multiplier": 1.25,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.0
	},
	{
		"name": "Точный",
		"description": "Летит резко и точно.",
		"speed_multiplier": 1.14,
		"hit_width_multiplier": 0.94,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.0
	},
	{
		"name": "Тяжёлый",
		"description": "Тяжёлый удар, широкий клинок.",
		"speed_multiplier": 0.82,
		"hit_width_multiplier": 1.22,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.45
	},
	{
		"name": "Золотой охотник",
		"description": "Лучше раскрывает золотые яблоки.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.02,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.5,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.0
	},
	{
		"name": "Меткий",
		"description": "Щедро награждает за меткий бросок.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.08,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.4,
		"hit_feedback_multiplier": 1.05
	},
	{
		"name": "Мастерский",
		"description": "Сбалансирован и приносит больше.",
		"speed_multiplier": 1.08,
		"hit_width_multiplier": 1.04,
		"apple_reward_multiplier": 1.15,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"hit_feedback_multiplier": 1.0
	}
]

const LEVEL_COUNT = 6
var current_level: int = 0
var current_knife_index: int = 0

var total_levels_passed: int = 0
var max_level_record: int = 0

# Combo system
var current_combo: int = 0
var combo_multiplier: float = 1.0
const COMBO_MULTIPLIER_STEP: float = 0.1
const MAX_COMBO_MULTIPLIER: float = 3.0

# Settings
var music_volume: float = 0.8
var sfx_volume: float = 0.8

var knife_prices: Array[int] = [
	250,  500, 1000,
	2000, 2500, 3000,
	3500, 4000, 4500
]

func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	rmg.randomize()
	_load_progress()
	Events.location_changed.connect(handle_location_change)


func handle_location_change(location: Events.LOCATIONS) -> void:
	get_tree().change_scene_to_packed(location_to_scene.get(location))


func get_knife_data(index: int) -> Dictionary:
	if index < 0 or index >= KNIFE_DATA.size():
		return DEFAULT_KNIFE_DATA
	return KNIFE_DATA[index]


func get_current_knife_data() -> Dictionary:
	return get_knife_data(current_knife_index)


func get_current_knife_stat(stat_name: String, default_value: float = 1.0) -> float:
	return float(get_current_knife_data().get(stat_name, default_value))


func apply_current_knife_reward_multiplier(amount: int) -> int:
	return _apply_reward_multiplier(amount, get_current_knife_stat("apple_reward_multiplier"))


func apply_current_knife_golden_multiplier(amount: int) -> int:
	return _apply_reward_multiplier(amount, get_current_knife_stat("golden_reward_multiplier"))


func _apply_reward_multiplier(amount: int, multiplier: float) -> int:
	if amount <= 0:
		return 0
	if multiplier <= 1.0:
		return amount
	return max(amount + 1, int(round(float(amount) * multiplier)))


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


func increase_combo() -> void:
	current_combo += 1
	combo_multiplier = min(1.0 + (current_combo - 1) * COMBO_MULTIPLIER_STEP, MAX_COMBO_MULTIPLIER)
	Events.combo_changed.emit(current_combo, combo_multiplier)


func reset_combo() -> void:
	if current_combo > 0:
		Events.combo_broken.emit()
	current_combo = 0
	combo_multiplier = 1.0
	Events.combo_changed.emit(current_combo, combo_multiplier)


func get_combo_bonus_apples(base_apples: int) -> int:
	return int(base_apples * combo_multiplier)


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


func get_unlock_cost() -> int:
	var unlocked_count := 0
	for i in range(unlocked_knives.size()):
		if unlocked_knives[i]:
			unlocked_count += 1

	var index = clamp(unlocked_count - 1, 0, knife_prices.size() - 1)
	return knife_prices[index]


func reset_to_first_level() -> void:
	current_level = 0
	total_levels_passed = 0
	_save_progress()


func reset_full_progress() -> void:
	apples = 0
	current_level = 0
	current_knife_index = 0
	total_levels_passed = 0
	max_level_record = 0
	_init_knives()
	_save_progress()
	Events.apples_changed.emit(apples)


func go_to_next_level() -> void:
	total_levels_passed += 1

	var is_boss := current_level == LEVEL_COUNT - 1
	if is_boss:
		_check_record_and_reward()

	current_level += 1
	if current_level >= LEVEL_COUNT:
		current_level = 0
	_save_progress()
	Events.location_changed.emit(Events.LOCATIONS.GAME)


func _check_record_and_reward() -> void:
	var current_total := total_levels_passed
	if current_total <= max_level_record:
		return

	var base_reward := 10
	var knife_factor := float(current_knife_index + 1)
	var step := 0.2 * knife_factor
	var record_multiplier := float(current_total)
	var reward := int(round(base_reward + step * record_multiplier))

	if reward <= 0:
		return

	add_apples(reward)
	max_level_record = current_total


func get_current_knife_price() -> int:
	if current_knife_index < 0 or current_knife_index >= knife_prices.size():
		return knife_prices[0]
	return knife_prices[current_knife_index]


func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "apples", apples)
	config.set_value("progress", "current_level", current_level)
	config.set_value("progress", "current_knife_index", current_knife_index)
	config.set_value("progress", "unlocked_knives", unlocked_knives)
	config.set_value("progress", "total_levels_passed", total_levels_passed)
	config.set_value("progress", "max_level_record", max_level_record)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.save("user://save.cfg")


func _load_progress() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://save.cfg")
	if err != OK:
		_init_knives()
		return

	apples = int(config.get_value("progress", "apples", 0))
	current_level = int(config.get_value("progress", "current_level", 0))
	current_knife_index = int(config.get_value("progress", "current_knife_index", 0))
	unlocked_knives = config.get_value("progress", "unlocked_knives", [])

	total_levels_passed = int(config.get_value("progress", "total_levels_passed", 0))
	max_level_record = int(config.get_value("progress", "max_level_record", 0))

	music_volume = float(config.get_value("settings", "music_volume", 0.8))
	sfx_volume = float(config.get_value("settings", "sfx_volume", 0.8))

	if unlocked_knives.size() != KNIVES_COUNT:
		_init_knives()
	else:
		Events.apples_changed.emit(apples)
		Events.knives_changed.emit()

	_apply_audio_settings()


func _apply_audio_settings() -> void:
	var music_bus_idx := AudioServer.get_bus_index("Music")
	var sfx_bus_idx := AudioServer.get_bus_index("SFX")

	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))


func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var music_bus_idx := AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	_save_progress()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var sfx_bus_idx := AudioServer.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
	_save_progress()
