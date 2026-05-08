extends Node2D
class_name Apple

const EXPOSION_TIME := 1.0
const GOLDEN_REWARD_MULTIPLIER := 10
const GOLDEN_PARTICLE_TINT := Color(1.0, 0.88, 0.12, 1.0)
const GOLDEN_AURA_SIZE := 96
const GOLDEN_AURA_COLOR := Color(1.0, 0.82, 0.08, 0.42)
const GOLDEN_SHADER_CODE := """
shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.82, 0.56, 0.0, 1.0);
uniform vec4 gold_color : source_color = vec4(1.0, 0.9, 0.02, 1.0);
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.72, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float luma = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 gold = mix(shadow_color.rgb, gold_color.rgb, smoothstep(0.12, 0.7, luma));
	gold = mix(gold, highlight_color.rgb, smoothstep(0.58, 0.96, luma));
	COLOR = vec4(gold, tex.a) * COLOR;
}
"""

var is_hitted := false 
var is_golden := false
var golden_aura: Sprite2D
var golden_aura_tween: Tween
@onready var particles := [
	$AppleParticles2D, 
	$AppleParticles2D2
]
@onready var sprite := $Sprite2D


func _ready() -> void:
	_apply_variant()


func make_golden() -> void:
	is_golden = true
	_apply_variant()


func _apply_variant() -> void:
	if is_golden and sprite:
		var shader := Shader.new()
		shader.code = GOLDEN_SHADER_CODE
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		sprite.material = shader_material
		sprite.z_index = 3
		_ensure_golden_aura()
		for particle in particles:
			if particle:
				particle.modulate = GOLDEN_PARTICLE_TINT


func _ensure_golden_aura() -> void:
	if golden_aura or not sprite:
		return
	golden_aura = Sprite2D.new()
	golden_aura.name = "GoldenAura"
	golden_aura.texture = _create_golden_aura_texture()
	golden_aura.position = sprite.position
	golden_aura.z_index = 2
	golden_aura.modulate = Color(1, 1, 1, 0.6)
	golden_aura.scale = Vector2(0.92, 0.92)
	add_child(golden_aura)
	move_child(golden_aura, 0)

	golden_aura_tween = create_tween()
	golden_aura_tween.set_loops()
	golden_aura_tween.tween_property(golden_aura, "scale", Vector2(1.18, 1.18), 0.7)
	golden_aura_tween.parallel().tween_property(golden_aura, "modulate:a", 0.2, 0.7)
	golden_aura_tween.tween_property(golden_aura, "scale", Vector2(0.92, 0.92), 0.7)
	golden_aura_tween.parallel().tween_property(golden_aura, "modulate:a", 0.6, 0.7)


func _create_golden_aura_texture() -> Texture2D:
	var image := Image.create(GOLDEN_AURA_SIZE, GOLDEN_AURA_SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(GOLDEN_AURA_SIZE, GOLDEN_AURA_SIZE) * 0.5
	var radius := float(GOLDEN_AURA_SIZE) * 0.5
	for y in range(GOLDEN_AURA_SIZE):
		for x in range(GOLDEN_AURA_SIZE):
			var distance: float = Vector2(x, y).distance_to(center) / radius
			var alpha: float = clampf(1.0 - distance, 0.0, 1.0)
			alpha = alpha * alpha * GOLDEN_AURA_COLOR.a
			image.set_pixel(x, y, Color(GOLDEN_AURA_COLOR.r, GOLDEN_AURA_COLOR.g, GOLDEN_AURA_COLOR.b, alpha))
	return ImageTexture.create_from_image(image)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_hitted:
		is_hitted = true
		if golden_aura_tween:
			golden_aura_tween.kill()
		if golden_aura:
			golden_aura.hide()
		sprite.hide()
		var reward_amount := 1
		if Globals.current_level == Globals.LEVEL_COUNT - 1:
			var boss_index := int(Globals.total_levels_passed / Globals.LEVEL_COUNT) + 1
			reward_amount = boss_index * 10
		reward_amount = Globals.apply_current_knife_reward_multiplier(reward_amount)
		if is_golden:
			reward_amount *= GOLDEN_REWARD_MULTIPLIER
			reward_amount = Globals.apply_current_knife_golden_multiplier(reward_amount)

		var target: Target = _find_target()
		if target != null:
			target.register_apple_hit(reward_amount, body)
		else:
			Globals.add_apples(reward_amount)

		var tween = create_tween()
		for particle in particles:
			particle.emitting = true
			tween.parallel().tween_property(particle, "modulate", Color("ffffff00"), EXPOSION_TIME)

		tween.play()

		await tween.finished
		queue_free()


func _find_target() -> Target:
	var node := get_parent()
	while node and not (node is Target):
		node = node.get_parent()
	if node is Target:
		return node
	return null
