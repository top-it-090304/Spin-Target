extends CharacterBody2D
class_name Knife

enum State {IDLE, FLY_TO_TARGET, FLY_AWAY}
const TrailMoteScript := preload("res://elements/knife/knife_trail_mote.gd")
const TRAIL_MAX_LENGTH := 46.0

var state := State.IDLE

var speed := 4500.0
var fly_away_speed := 1000.0
var fly_away_rotation_speed := 1500.0
var fly_away_diraction := Vector2.DOWN
var flay_away_diviation := PI / 8.0
var trail_line: Line2D
var trail_tick := 0.0
var knife_data := {}
var effect_color := Color(1.0, 0.9, 0.45, 1.0)
var trail_kind := 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_hit: AudioStreamPlayer = $AudioHit
@onready var audio_wood: AudioStreamPlayer = $AudioWood


func _ready() -> void:
	_apply_current_knife_stats()
	_update_texture()

func change_state(new_state: State):
	state = new_state

func _physics_process(delta: float):
	match state:
		State.FLY_AWAY:
			global_position += fly_away_diraction * fly_away_speed * delta
			rotation += fly_away_rotation_speed * delta
	
		State.FLY_TO_TARGET:
			_update_trail(delta)
			var flight_speed := speed * Globals.get_current_knife_stat("speed_multiplier")
			var collision := move_and_collide(Vector2.UP * flight_speed * delta)
			if collision:
				handle_collision(collision)

func throw_away(direction: Vector2):
	var diraction_diviation = Globals.rmg.randf_range(-flay_away_diviation, flay_away_diviation)
	fly_away_diraction = direction.rotated(diraction_diviation)
	change_state(State.FLY_AWAY)

func throw():
	_apply_current_knife_stats()
	change_state(State.FLY_TO_TARGET)
	_update_texture()
	_start_trail()

func handle_collision(collision: KinematicCollision2D):
	_finish_trail()
	var collider := collision.get_collider()
	if collider is Target:
		_play_wood_hit_sound()
		collider.play_hit_feedback(
			collision.get_position(),
			Globals.get_current_knife_data()
		)
		add_knife_to_target(collider)
		change_state(State.IDLE)
		# Увеличиваем комбо при успешном попадании
		Globals.increase_combo()
	elif collider is Knife:
		_play_hit_sound()
		throw_away(collision.get_normal())
		# Сбрасываем комбо при столкновении с другим ножом
		Globals.reset_combo()
	else:
		_play_wood_hit_sound()
		throw_away(collision.get_normal())
		# Сбрасываем комбо при промахе
		Globals.reset_combo()


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


func _apply_current_knife_stats() -> void:
	knife_data = Globals.get_current_knife_data()
	effect_color = knife_data.get("effect_color", Color(1.0, 0.9, 0.45, 1.0))
	trail_kind = int(knife_data.get("trail_kind", 0))
	if collision_shape:
		var hit_width := Globals.get_current_knife_stat("hit_width_multiplier")
		collision_shape.scale = Vector2(hit_width, 1.0)


func _start_trail() -> void:
	_finish_trail(false)
	var parent := get_parent() as Node2D
	if parent == null:
		return
	trail_line = Line2D.new()
	trail_line.name = "KnifeTrail"
	trail_line.top_level = true
	trail_line.z_index = 16
	trail_line.width = _get_trail_width()
	trail_line.default_color = Color(effect_color.r, effect_color.g, effect_color.b, _get_trail_alpha())
	trail_line.joint_mode = Line2D.LINE_JOINT_ROUND
	trail_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	parent.add_child(trail_line)
	trail_tick = 0.0


func _finish_trail(fade := true) -> void:
	if not trail_line:
		return
	var line := trail_line
	trail_line = null
	if fade and line.is_inside_tree():
		var tween := line.create_tween()
		tween.tween_property(line, "modulate:a", 0.0, 0.16)
		tween.tween_callback(line.queue_free)
	else:
		line.queue_free()


func _update_trail(delta: float) -> void:
	if not trail_line:
		return
	var tail_direction := Vector2.DOWN.rotated(global_rotation)
	trail_line.clear_points()
	trail_line.add_point(global_position + tail_direction * 14.0)
	trail_line.add_point(global_position + tail_direction * _get_trail_length())
	trail_tick += delta
	if trail_tick >= _get_mote_interval():
		trail_tick = 0.0
		_spawn_trail_mote()


func _spawn_trail_mote() -> void:
	if trail_kind == 0 or trail_kind == 1 or trail_kind == 4:
		return
	var parent := get_parent() as Node2D
	if parent == null:
		return
	var mote := TrailMoteScript.new()
	mote.color = effect_color
	mote.radius = _get_mote_radius()
	mote.lifetime = 0.16 if trail_kind != 5 else 0.22
	mote.global_position = global_position + Vector2(Globals.rmg.randf_range(-7.0, 7.0), Globals.rmg.randf_range(4.0, 12.0))
	mote.drift = Vector2(Globals.rmg.randf_range(-12.0, 12.0), Globals.rmg.randf_range(24.0, 48.0))
	parent.add_child(mote)


func _get_trail_width() -> float:
	match trail_kind:
		1:
			return 2.4
		2:
			return 6.0
		5:
			return 5.5
		7:
			return 2.0
		8:
			return 4.0
		_:
			return 3.5


func _get_trail_length() -> float:
	match trail_kind:
		1:
			return 54.0
		2:
			return 38.0
		4:
			return 42.0
		5:
			return 32.0
		7:
			return 48.0
		_:
			return TRAIL_MAX_LENGTH


func _get_trail_alpha() -> float:
	match trail_kind:
		5:
			return 0.24
		7:
			return 0.52
		_:
			return 0.34


func _get_mote_interval() -> float:
	match trail_kind:
		3, 6:
			return 0.06
		5:
			return 0.08
		8:
			return 0.08
		_:
			return 0.1


func _get_mote_radius() -> float:
	match trail_kind:
		2:
			return 3.2
		5:
			return 4.0
		6:
			return 3.0
		_:
			return 2.4
