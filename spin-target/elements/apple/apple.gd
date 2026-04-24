extends Node2D
class_name Apple

const EXPOSION_TIME := 1.0

var is_hitted := false 
@onready var particles := [
	$AppleParticles2D, 
	$AppleParticles2D2
]
@onready var sprite := $Sprite2D

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not is_hitted:
		is_hitted = true
		sprite.hide()
		var reward_amount := 1
		if Globals.current_level == Globals.LEVEL_COUNT - 1:
			var boss_index := int(Globals.total_levels_passed / Globals.LEVEL_COUNT) + 1
			reward_amount = boss_index * 10

		var target: Target = _find_target()
		if target != null:
			target.show_apple_reward_gained(reward_amount)
		else:
			Globals.add_apples(reward_amount)

		var tween = create_tween()
		for particle in particles:
			particle.emitting = true
			tween.parallel().tween_property(particle, "modulate", Color("ffffff00"), EXPOSION_TIME)

		tween.play()

		if target != null:
			target.on_apple_hit()

		await tween.finished
		queue_free()


func _find_target() -> Target:
	var node := get_parent()
	while node and not (node is Target):
		node = node.get_parent()
	if node is Target:
		return node
	return null
