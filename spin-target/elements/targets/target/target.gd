extends CharacterBody2D
class_name Target

const GENERATION_LIMIT := 10
const KNIFE_POSITION := Vector2(0, 180)
const APPLE_POSITION := Vector2(0, 176)
const OBJECT_MARGIN := PI / 6
const APPLE_NUMBER_ON_TARGET = 5
const KNIFE_NUMBER_ON_TARGET = 4

var knife_scene : PackedScene = load("res://elements/knife/knife.tscn")
var apple_scene : PackedScene = load("res://elements/apple/apple.tscn")

var speed := PI

@onready var items_container := $ItemsContainer

func _physics_process(delta: float):
	rotation += speed * delta


func _ready():
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
