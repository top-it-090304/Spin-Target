extends Node2D

const EXPOSION_TIME := 1.0

var is_hitted := false 
@onready var particles := [
	$AppleParticles2D, 
	$AppleParticles2D2
]
@onready var sprite := $Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_hitted:
		is_hitted = true
		sprite.hide()
		var tween = create_tween()
		for particle in particles:
			particle.emitting = true
			tween.parallel().tween_property(particle, "modulate", Color("ffffff00"), EXPOSION_TIME)

		tween.play()
		await tween.finished
		queue_free()
