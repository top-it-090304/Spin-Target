extends Node2D

var color := Color.WHITE
var radius := 4.0
var lifetime := 0.28
var age := 0.0
var drift := Vector2.ZERO


func _ready() -> void:
	z_index = 18


func _process(delta: float) -> void:
	age += delta
	position += drift * delta
	queue_redraw()
	if age >= lifetime:
		queue_free()


func _draw() -> void:
	var t := clampf(age / lifetime, 0.0, 1.0)
	var draw_color := Color(color.r, color.g, color.b, color.a * (1.0 - t))
	draw_circle(Vector2.ZERO, radius * (1.0 - t * 0.45), draw_color)
