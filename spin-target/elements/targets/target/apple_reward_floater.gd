extends Node2D

## За n-е попадание подряд начисляется base×n; подпись показывает ровно эту сумму (+1, +2, +3…).

var _text: String = ""
var _age: float = 0.0
var _rise_offset := Vector2.ZERO
var _fill_color := Color(1.0, 0.92, 0.28, 1.0)
const DURATION := 1.05
const FONT_SIZE := 80


func _ready() -> void:
	z_index = 48
	top_level = true
	set_process(false)


func show_gain(amount: int, hit_count: int = 1) -> void:
	if amount <= 0:
		return
	_text = _format_text(amount, hit_count)
	_fill_color = Color(1.0, 0.92, 0.28, 1.0)
	if hit_count >= 2:
		_fill_color = Color(1.0, 0.72, 0.12, 1.0)
	Globals.add_apples(amount)

	_age = 0.0
	_rise_offset = Vector2.ZERO
	modulate = Color(1, 1, 1, 1)
	global_rotation = 0.0
	_sync_position_from_parent()
	set_process(true)
	queue_redraw()


func stop_and_clear() -> void:
	_finish()


func _finish() -> void:
	_text = ""
	_rise_offset = Vector2.ZERO
	set_process(false)
	modulate = Color(1, 1, 1, 1)
	queue_redraw()


func _format_text(amount: int, hit_count: int) -> String:
	if hit_count == 2:
		return "Я даю яблок больше +%d" % amount
	if hit_count >= 3:
		return "Я даю яблок больше x%d +%d" % [hit_count, amount]
	return "+%d" % amount


func _sync_position_from_parent() -> void:
	var p := get_parent() as Node2D
	if p == null:
		return
	global_position = p.global_position + _rise_offset
	global_rotation = 0.0


func _process(delta: float) -> void:
	var p := get_parent() as Node2D
	if p == null:
		_finish()
		return

	_age += delta
	_rise_offset.y -= 50.0 * delta
	_sync_position_from_parent()

	var t := clampf(_age / DURATION, 0.0, 1.0)
	modulate.a = 1.0 - (t * t)
	queue_redraw()
	if _age >= DURATION:
		_finish()


func _draw() -> void:
	if _text.is_empty():
		return
	var font := ThemeDB.fallback_font
	var fs := FONT_SIZE
	var sz := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var pos := Vector2(-sz.x * 0.5, -fs * 0.46)
	var shadow := Color(0.06, 0.03, 0.08, modulate.a * 0.55)
	for ox in [-3, -2, -1, 0, 1, 2, 3]:
		for oy in [-3, -2, -1, 0, 1, 2, 3]:
			if ox == 0 and oy == 0:
				continue
			draw_string(
				font,
				pos + Vector2(ox, oy) * 0.55,
				_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				fs,
				shadow
			)
	var fill := Color(_fill_color.r, _fill_color.g, _fill_color.b, modulate.a)
	draw_string(font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, fill)
