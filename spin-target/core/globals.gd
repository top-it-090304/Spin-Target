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
	"weight": 1.0,
	"apple_reward_multiplier": 1.0,
	"golden_reward_multiplier": 1.0,
	"sharp_hit_multiplier": 1.0,
	"effect_color": Color(1.0, 0.9, 0.45, 1.0),
	"trail_kind": 0,
	"hit_effect_kind": 0
}
const KNIFE_DATA := [
	{
		"name": "Обычный",
		"description": "Надёжный стартовый нож.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.0,
		"weight": 1.0,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(1.0, 0.9, 0.45, 1.0),
		"trail_kind": 0,
		"hit_effect_kind": 0
	},
	{
		"name": "Быстрый",
		"description": "Быстро летит к мишени.",
		"speed_multiplier": 1.22,
		"hit_width_multiplier": 0.88,
		"weight": 0.75,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(0.42, 0.86, 1.0, 1.0),
		"trail_kind": 1,
		"hit_effect_kind": 1
	},
	{
		"name": "Широкий",
		"description": "Проще задевает яблоки.",
		"speed_multiplier": 0.9,
		"hit_width_multiplier": 1.28,
		"weight": 1.05,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(1.0, 0.76, 0.28, 1.0),
		"trail_kind": 2,
		"hit_effect_kind": 2
	},
	{
		"name": "Садовый",
		"description": "Даёт больше яблок за сбор.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.0,
		"weight": 0.95,
		"apple_reward_multiplier": 1.25,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(0.45, 1.0, 0.48, 1.0),
		"trail_kind": 3,
		"hit_effect_kind": 3
	},
	{
		"name": "Точный",
		"description": "Летит резко и точно.",
		"speed_multiplier": 1.14,
		"hit_width_multiplier": 0.94,
		"weight": 0.85,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(0.9, 0.96, 1.0, 1.0),
		"trail_kind": 4,
		"hit_effect_kind": 4
	},
	{
		"name": "Тяжёлый",
		"description": "Тяжёлый удар, широкий клинок.",
		"speed_multiplier": 0.82,
		"hit_width_multiplier": 1.22,
		"weight": 1.65,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(1.0, 0.45, 0.28, 1.0),
		"trail_kind": 5,
		"hit_effect_kind": 5
	},
	{
		"name": "Золотой охотник",
		"description": "Лучше раскрывает золотые яблоки.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.02,
		"weight": 1.25,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.5,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(1.0, 0.86, 0.12, 1.0),
		"trail_kind": 6,
		"hit_effect_kind": 6
	},
	{
		"name": "Меткий",
		"description": "Щедро награждает за меткий бросок.",
		"speed_multiplier": 1.0,
		"hit_width_multiplier": 1.08,
		"weight": 1.0,
		"apple_reward_multiplier": 1.0,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.4,
		"effect_color": Color(1.0, 0.98, 0.62, 1.0),
		"trail_kind": 7,
		"hit_effect_kind": 7
	},
	{
		"name": "Мастерский",
		"description": "Сбалансирован и приносит больше.",
		"speed_multiplier": 1.08,
		"hit_width_multiplier": 1.04,
		"weight": 1.05,
		"apple_reward_multiplier": 1.15,
		"golden_reward_multiplier": 1.0,
		"sharp_hit_multiplier": 1.0,
		"effect_color": Color(0.66, 0.9, 1.0, 1.0),
		"trail_kind": 8,
		"hit_effect_kind": 8
	}
]

const LEVEL_COUNT = 6
var current_level: int = 0
var current_knife_index: int = 0

var total_levels_passed: int = 0
var max_level_record: int = 0
var level_apples_gained: int = 0
var level_throws: int = 0
var level_sharp_hits: int = 0
var level_golden_apples: int = 0
var level_completed_recorded: bool = false
var run_apples_gained: int = 0
var run_throws: int = 0
var run_sharp_hits: int = 0
var run_golden_apples: int = 0
var run_levels_completed: int = 0
var run_max_level: int = 0
var best_runs: Array = []
const BEST_RUNS_LIMIT := 5

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
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(540, 960))
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


func get_knife_stat_lines(index: int) -> Array[String]:
	var rows := get_knife_stat_rows(index)
	var lines: Array[String] = []
	for row in rows:
		lines.append("%s: %s" % [String(row.get("title", "")), String(row.get("value", ""))])
	return lines


func get_knife_stat_rows(index: int) -> Array[Dictionary]:
	var data := get_knife_data(index)
	var speed_multiplier := float(data.get("speed_multiplier", 1.0))
	var hit_width_multiplier := float(data.get("hit_width_multiplier", 1.0))
	var weight := float(data.get("weight", 1.0))
	var apple_multiplier := float(data.get("apple_reward_multiplier", 1.0))
	var golden_multiplier := float(data.get("golden_reward_multiplier", 1.0))
	var sharp_multiplier := float(data.get("sharp_hit_multiplier", 1.0))
	return [
		{
			"title": "Скорость",
			"value": _get_speed_label(speed_multiplier),
			"level": _get_speed_level(speed_multiplier),
			"kind": 0,
			"color": Color(0.45, 0.83, 1.0, 1.0)
		},
		{
			"title": "Клинок",
			"value": _get_blade_label(hit_width_multiplier),
			"level": _get_blade_level(hit_width_multiplier),
			"kind": 1,
			"color": Color(1.0, 0.88, 0.32, 1.0)
		},
		{
			"title": "Вес",
			"value": _get_weight_label(weight),
			"level": _get_weight_level(weight),
			"kind": 2,
			"color": Color(1.0, 0.53, 0.32, 1.0)
		},
		{
			"title": "Бонус",
			"value": _get_bonus_label(apple_multiplier, golden_multiplier, sharp_multiplier),
			"level": _get_bonus_level(apple_multiplier, golden_multiplier, sharp_multiplier),
			"kind": 3,
			"color": Color(0.53, 1.0, 0.48, 1.0)
		}
	]


func _get_speed_level(multiplier: float) -> int:
	if multiplier >= 1.18:
		return 5
	if multiplier >= 1.08:
		return 4
	if multiplier <= 0.9:
		return 2
	return 3


func _get_blade_level(multiplier: float) -> int:
	if multiplier >= 1.18:
		return 5
	if multiplier >= 1.06:
		return 4
	if multiplier <= 0.94:
		return 2
	return 3


func _get_weight_level(weight: float) -> int:
	if weight >= 1.45:
		return 5
	if weight >= 1.2:
		return 4
	if weight <= 0.9:
		return 2
	return 3


func _get_bonus_level(apple_multiplier: float, golden_multiplier: float, sharp_multiplier: float) -> int:
	var best_multiplier: float = max(apple_multiplier, max(golden_multiplier, sharp_multiplier))
	if best_multiplier >= 1.45:
		return 5
	if best_multiplier >= 1.25:
		return 4
	if best_multiplier > 1.0:
		return 3
	return 1


func _get_speed_label(multiplier: float) -> String:
	if multiplier >= 1.18:
		return "очень высокая"
	if multiplier >= 1.08:
		return "высокая"
	if multiplier <= 0.9:
		return "низкая"
	return "средняя"


func _get_blade_label(multiplier: float) -> String:
	if multiplier >= 1.18:
		return "широкий"
	if multiplier >= 1.06:
		return "чуть шире"
	if multiplier <= 0.94:
		return "узкий"
	return "обычный"


func _get_weight_label(weight: float) -> String:
	if weight >= 1.45:
		return "тяжёлый"
	if weight >= 1.2:
		return "увесистый"
	if weight <= 0.9:
		return "лёгкий"
	return "средний"


func _get_bonus_label(apple_multiplier: float, golden_multiplier: float, sharp_multiplier: float) -> String:
	var bonuses: Array[String] = []
	if apple_multiplier > 1.0:
		bonuses.append("яблоки +%d%%" % int(round((apple_multiplier - 1.0) * 100.0)))
	if golden_multiplier > 1.0:
		bonuses.append("золотые +%d%%" % int(round((golden_multiplier - 1.0) * 100.0)))
	if sharp_multiplier > 1.0:
		bonuses.append("Метко! +%d%%" % int(round((sharp_multiplier - 1.0) * 100.0)))
	if bonuses.is_empty():
		return "нет"
	return ", ".join(bonuses)


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


func start_level_run() -> void:
	level_apples_gained = 0
	level_throws = 0
	level_sharp_hits = 0
	level_golden_apples = 0
	level_completed_recorded = false


func start_new_run() -> void:
	run_apples_gained = 0
	run_throws = 0
	run_sharp_hits = 0
	run_golden_apples = 0
	run_levels_completed = 0
	run_max_level = current_level + 1
	start_level_run()


func register_throw() -> void:
	level_throws += 1
	run_throws += 1


func register_sharp_hit() -> void:
	level_sharp_hits += 1
	run_sharp_hits += 1


func register_golden_apple() -> void:
	level_golden_apples += 1
	run_golden_apples += 1


func register_level_completed() -> void:
	if level_completed_recorded:
		return
	level_completed_recorded = true
	run_levels_completed += 1
	run_max_level = max(run_max_level, run_levels_completed + 1)


func add_apples(amount: int, count_for_progress: bool = true) -> void:
	apples += amount
	if apples < 0:
		apples = 0
	if amount > 0 and count_for_progress:
		level_apples_gained += amount
		run_apples_gained += amount
	Events.apples_changed.emit(apples)
	_save_progress()


func get_level_result_lines() -> Array[String]:
	var lines: Array[String] = []
	lines.append("+%d" % level_apples_gained)
	lines.append("%d" % level_throws)
	lines.append("%d" % level_sharp_hits)
	lines.append("%d" % level_golden_apples)
	return lines


func get_run_result_cards() -> Array[Dictionary]:
	return [
		{"title": "Уровень", "value": str(run_max_level), "color": Color(0.08, 0.28, 0.46, 1.0)},
		{"title": "Яблоки", "value": "+%d" % run_apples_gained, "color": Color(0.36, 0.2, 0.02, 1.0)},
		{"title": "Метко!", "value": str(run_sharp_hits), "color": Color(0.48, 0.18, 0.02, 1.0)},
		{"title": "Золото", "value": str(run_golden_apples), "color": Color(0.42, 0.24, 0.0, 1.0)}
	]


func finish_current_run() -> void:
	if run_levels_completed <= 0 and run_apples_gained <= 0 and run_throws <= 0:
		return
	var run := {
		"level": run_max_level,
		"levels_completed": run_levels_completed,
		"apples": run_apples_gained,
		"sharp": run_sharp_hits,
		"golden": run_golden_apples,
		"throws": run_throws,
		"score": _get_run_score(run_max_level, run_apples_gained, run_sharp_hits, run_golden_apples)
	}
	best_runs.append(run)
	best_runs.sort_custom(_compare_runs)
	if best_runs.size() > BEST_RUNS_LIMIT:
		best_runs.resize(BEST_RUNS_LIMIT)
	_save_progress()


func get_best_run() -> Dictionary:
	if best_runs.is_empty():
		return {}
	return best_runs[0]


func get_best_run_rows() -> Array[Dictionary]:
	var best := get_best_run()
	if best.is_empty():
		return [
			{"title": "Уровень", "value": "0"},
			{"title": "Яблоки", "value": "0"},
			{"title": "Метко!", "value": "0"},
			{"title": "Золото", "value": "0"}
		]
	return [
		{"title": "Уровень", "value": str(int(best.get("level", 0)))},
		{"title": "Яблоки", "value": str(int(best.get("apples", 0)))},
		{"title": "Метко!", "value": str(int(best.get("sharp", 0)))},
		{"title": "Золото", "value": str(int(best.get("golden", 0)))}
	]


func get_best_runs_table() -> Array:
	return best_runs


func _get_run_score(level: int, apples_amount: int, sharp: int, golden: int) -> int:
	return level * 10000 + apples_amount * 20 + sharp * 500 + golden * 700


func _compare_runs(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("score", 0)) > int(b.get("score", 0))


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
	best_runs = []
	start_new_run()
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
	config.set_value("records", "best_runs", best_runs)
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
	best_runs = config.get_value("records", "best_runs", [])

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
