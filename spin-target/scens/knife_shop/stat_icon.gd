extends Control

enum Kind {SPEED, BLADE, WEIGHT, BONUS}

var kind: Kind = Kind.SPEED:
	set(value):
		kind = value
		queue_redraw()
var accent_color := Color(0.45, 0.83, 1.0, 1.0):
	set(value):
		accent_color = value
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(28, 22)


func _draw() -> void:
	match kind:
		Kind.SPEED:
			_draw_speed_icon()
		Kind.BLADE:
			_draw_blade_icon()
		Kind.WEIGHT:
			_draw_weight_icon()
		Kind.BONUS:
			_draw_bonus_icon()


func _draw_speed_icon() -> void:
	var y := size.y * 0.5
	var left := size.x * 0.18
	var right := size.x * 0.8
	draw_line(Vector2(left, y), Vector2(right, y), accent_color, 3.0)
	draw_colored_polygon([
		Vector2(right, y),
		Vector2(right - 7.0, y - 5.0),
		Vector2(right - 7.0, y + 5.0)
	], accent_color)
	draw_line(Vector2(left - 1.0, y - 5.0), Vector2(left + 9.0, y - 5.0), accent_color.darkened(0.15), 2.0)
	draw_line(Vector2(left - 4.0, y + 5.0), Vector2(left + 6.0, y + 5.0), accent_color.darkened(0.15), 2.0)


func _draw_blade_icon() -> void:
	var center := size * 0.5
	draw_colored_polygon([
		Vector2(center.x, 2.0),
		Vector2(size.x - 5.0, center.y),
		Vector2(center.x, size.y - 3.0),
		Vector2(5.0, center.y)
	], accent_color)
	draw_line(Vector2(center.x, 4.0), Vector2(center.x, size.y - 5.0), Color(1, 1, 1, 0.45), 1.5)


func _draw_weight_icon() -> void:
	var body_rect := Rect2(Vector2(5.0, 8.0), Vector2(size.x - 10.0, size.y - 10.0))
	draw_rect(body_rect, accent_color, true)
	draw_arc(Vector2(size.x * 0.5, 9.0), 6.0, PI, TAU, 16, accent_color, 2.5)
	draw_rect(body_rect, Color(0.08, 0.04, 0.03, 0.18), false, 1.0)


func _draw_bonus_icon() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.58)
	draw_circle(center, 7.0, accent_color)
	draw_circle(center + Vector2(-2.0, -2.0), 2.0, Color(1, 1, 1, 0.35))
	draw_line(Vector2(center.x + 2.0, center.y - 8.0), Vector2(center.x + 6.0, center.y - 13.0), accent_color.lightened(0.15), 2.0)
	draw_colored_polygon([
		Vector2(center.x + 5.0, center.y - 13.0),
		Vector2(center.x + 12.0, center.y - 14.0),
		Vector2(center.x + 8.0, center.y - 9.0)
	], accent_color.lightened(0.2))
