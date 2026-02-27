extends CharacterBody2D
class_name Target

const EXPOSION_TIME := 1.0
const GENERATION_LIMIT := 10
const KNIFE_POSITION := Vector2(0, 180)
const APPLE_POSITION := Vector2(0, 176)
const OBJECT_MARGIN := PI / 5
const APPLE_NUMBER_ON_TARGET := 8
const KNIFE_NUMBER_ON_TARGET := 3

var knife_scene : PackedScene = load("res://elements/knife/knife.tscn")
var apple_scene : PackedScene = load("res://elements/apple/apple.tscn")

var speed := PI

var remaining_apples: int = 0

@onready var items_container := $ItemsContainer
@onready var sprite := $Sprite2D
@onready var knife_particles := $KnifeParticles2D
@onready var target_particles := [
	$TargetParticles2D,
	$TargetParticles2D2,
	$TargetParticles2D3
]

func explode():
	if not is_inside_tree():
		return
	sprite.hide()
	items_container.hide()
	knife_particles.rotation = -rotation
	
	var tween := create_tween()	
	
	for target_particles_part in target_particles:
		tween.parallel().tween_property(target_particles_part, "modulate", Color("ffffff00"), EXPOSION_TIME)
		target_particles_part.emitting = true
		
	knife_particles.emitting = true
	tween.play()
	_play_explosion_sound()

func _physics_process(delta: float):
	rotation += speed * delta
	if remaining_apples > 0 and _get_apples_on_target() == 0:
		remaining_apples = 0
		_on_all_apples_collected()


func _ready():
	_setup_level()
	add_default_items(KNIFE_NUMBER_ON_TARGET, APPLE_NUMBER_ON_TARGET)

func add_default_items(knifes: int, apples: int):
	var occupied_rotations := []
	for i in range(knifes):
		var pivot_rotation = get_free_random_rotation(occupied_rotations)
		if pivot_rotation == null:
			return
		occupied_rotations.append(pivot_rotation)
		var knife = knife_scene.instantiate()
		knife.position = KNIFE_POSITION
		add_object_with_pivot(knife, pivot_rotation)
		
	remaining_apples = apples
	for i in range(apples):
		var pivot_rotation = get_free_random_rotation(occupied_rotations)
		if pivot_rotation == null:
			return
		occupied_rotations.append(pivot_rotation)
		var apple = apple_scene.instantiate()
		apple.position = APPLE_POSITION
		add_object_with_pivot(apple, pivot_rotation)
		
	
		


func add_object_with_pivot(object: Node2D, object_rotation: float):
	var pivot := Node2D.new()
	pivot.rotation = object_rotation
	pivot.add_child(object)
	items_container.add_child(pivot)
	
func get_free_random_rotation(occupied_rotations: Array, generation_attemps=0):
	var random_rotation = Globals.rmg.randf_range(0, PI * 2)
	if generation_attemps >= GENERATION_LIMIT:
		return null
	
	for occupied in occupied_rotations:
		if random_rotation <= occupied + OBJECT_MARGIN / 2.0 and \
		   random_rotation >= occupied - OBJECT_MARGIN / 2.0:
			return get_free_random_rotation(occupied_rotations, generation_attemps + 1)
	
	return random_rotation


func on_apple_hit() -> void:
	remaining_apples -= 1
	if remaining_apples <= 0:
		_on_all_apples_collected()


func _on_all_apples_collected() -> void:
	explode()
	var banner := get_tree().get_first_node_in_group("win_banner")
	if banner:
		banner.call("show_banner_and_next_level")
	else:
		Globals.go_to_next_level()


func _setup_level() -> void:
	var level_index := Globals.current_level
	var sprite_texture_path := "res://assets/target%d.png" % (level_index + 1)
	var sprite_texture := load(sprite_texture_path)
	if sprite_texture and sprite:
		sprite.texture = sprite_texture

	var particles_base_path := "res://assets/target%d_" % (level_index + 1)
	var textures := [
		load(particles_base_path + "1.png"),
		load(particles_base_path + "2.png"),
		load(particles_base_path + "3.png")
	]

	for i in range(target_particles.size()):
		if i < textures.size() and textures[i]:
			target_particles[i].texture = textures[i]
	# текстура ножей в частицах должна совпадать с выбранным ножом
	var knife_index := Globals.current_knife_index + 1
	if knife_index < 1:
		knife_index = 1
	if knife_index > 9:
		knife_index = 9
	var knife_texture_path := "res://assets/knife%d.png" % knife_index
	var knife_texture := load(knife_texture_path)
	if knife_texture and knife_particles:
		knife_particles.texture = knife_texture


func _play_explosion_sound() -> void:
	var audio := $AudioExplosion
	if audio:
		audio.play()


func _get_apples_on_target() -> int:
	var count := 0
	for pivot in items_container.get_children():
		for child in pivot.get_children():
			if child is Apple:
				count += 1
	return count
