extends Node2D

var is_hitted := false 

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_hitted:
		is_hitted = true
		queue_free()
