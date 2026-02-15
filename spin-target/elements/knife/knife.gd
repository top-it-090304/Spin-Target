extends CharacterBody2D

enum State {IDLE, FLY_TO_TARGET, FLY_AWAY}
var state := State.IDLE

var speed := 4500.0
var fly_away_speed := 1000.0
var fly_away_rotation_speed := 1500.0
var fly_away_diraction := Vector2.DOWN
var flay_away_diviation := PI / 8.0

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

func handle_collision(collision: KinematicCollision2D):
	var collider := collision.get_collider()
	if collider is Target:
		add_knife_to_target(collider)
		change_state(State.IDLE)
	else:
		throw_away(collision.get_normal())

func add_knife_to_target(target: Target):
	get_parent().remove_child(self)
	global_position = Target.KNIFE_POSITION
	rotation = 0
	target.add_object_with_pivot(self, -target.rotation)
	
