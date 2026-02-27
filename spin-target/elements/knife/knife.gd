extends CharacterBody2D

enum State {IDLE, FLY_TO_TARGET, FLY_AWAY}
var state := State.IDLE

var speed := 4500.0
var fly_away_speed := 1000.0
var fly_away_rotation_speed := 1500.0
var fly_away_diraction := Vector2.DOWN
var flay_away_diviation := PI / 8.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_hit: AudioStreamPlayer = $AudioHit
@onready var audio_wood: AudioStreamPlayer = $AudioWood


func _ready() -> void:
	_update_texture()

func change_state(new_state: State):
	state = new_state

func _physics_process(delta: float):
	match state:
		State.FLY_AWAY:
			global_position += fly_away_diraction * fly_away_speed * delta
			rotation += fly_away_rotation_speed * delta
	
		State.FLY_TO_TARGET:
			var collision := move_and_collide(Vector2.UP * speed * delta)
			if collision:
				handle_collision(collision)

func throw_away(direction: Vector2):
	var diraction_diviation = Globals.rmg.randf_range(-flay_away_diviation, flay_away_diviation)
	fly_away_diraction = direction.rotated(diraction_diviation)
	change_state(State.FLY_AWAY)

func throw():
	change_state(State.FLY_TO_TARGET)
	_update_texture()

func handle_collision(collision: KinematicCollision2D):
	var collider := collision.get_collider()
	if collider is Target:
		_play_hit_sound()
		add_knife_to_target(collider)
		change_state(State.IDLE)
	else:
		_play_wood_hit_sound()
		throw_away(collision.get_normal())


func _play_hit_sound() -> void:
	if not is_inside_tree():
		return
	if audio_hit:
		audio_hit.play()


func _play_wood_hit_sound() -> void:
	if not is_inside_tree():
		return
	if audio_wood:
		audio_wood.play()

func add_knife_to_target(target: Target):
	get_parent().remove_child(self)
	global_position = Target.KNIFE_POSITION
	rotation = 0
	target.add_object_with_pivot(self, -target.rotation)


func _update_texture() -> void:
	if not sprite:
		return
	var knife_index := Globals.current_knife_index + 1
	if knife_index < 1:
		knife_index = 1
	if knife_index > 9:
		knife_index = 9
	var texture_path := "res://assets/knife%d.png" % knife_index
	var texture := load(texture_path)
	if texture:
		sprite.texture = texture
