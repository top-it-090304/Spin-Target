extends Node

const CATEGORY_NORMAL := "normal"
const CATEGORY_BOSS := "boss"

const NORMAL_TRACKS: Array[String] = [
	"res://music/normal/2-ABOVE-ZERO.ogg",
	"res://music/normal/AcousticRock.ogg",
	"res://music/normal/AwayInAMangerEDM.ogg",
	"res://music/normal/BlackFly.ogg",
	"res://music/normal/ChecksForFree.ogg",
	"res://music/normal/Continuum_1.ogg",
	"res://music/normal/Flo_Rida_-_Right_Round__SkySound.cc_.ogg",
	"res://music/normal/cairn_-_spin_around__SkySound.cc_.ogg",
]

const BOSS_TRACKS: Array[String] = [
	"res://music/boss/BanjoHop.ogg",
	"res://music/boss/BustinLoose.ogg",
	"res://music/boss/HeavyAction.ogg",
	"res://music/boss/HeroInPeril.ogg",
	"res://music/boss/IntroAction.ogg",
	"res://music/boss/TurnUpTheWatts.ogg",
]

var _player: AudioStreamPlayer
var _current_category: StringName = ""
var _last_normal_index: int = -1
var _last_boss_index: int = -1


func _ready() -> void:
	_init_player()


func _init_player() -> void:
	if _player:
		return
	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	add_child(_player)


func set_music_for_level(level_index: int) -> void:
	_init_player()

	var last_level := Globals.LEVEL_COUNT - 1
	var is_boss_level := level_index == last_level
	var is_preboss_level := level_index == last_level - 1

	var desired_category := CATEGORY_NORMAL
	if is_boss_level or is_preboss_level:
		desired_category = CATEGORY_BOSS

	# не переключаем трек, если категория не меняется
	if desired_category == _current_category and _player.stream and _player.playing:
		return

	_current_category = desired_category

	if desired_category == CATEGORY_BOSS:
		_play_random_track(BOSS_TRACKS, true)
	else:
		_play_random_track(NORMAL_TRACKS, false)


func _play_random_track(tracks: Array[String], is_boss: bool) -> void:
	if tracks.is_empty():
		return

	var last_index := _last_boss_index if is_boss else _last_normal_index
	var next_index := _pick_random_index(tracks.size(), last_index)

	var stream_path := tracks[next_index]
	var stream := load(stream_path)
	if not stream:
		return

	if stream is AudioStreamOggVorbis:
		stream.loop = true

	_player.stream = stream
	_player.play()

	if is_boss:
		_last_boss_index = next_index
	else:
		_last_normal_index = next_index


func _pick_random_index(count: int, last_index: int) -> int:
	if count <= 1:
		return 0

	var idx := Globals.rmg.randi_range(0, count - 1)
	if idx == last_index:
		idx = (idx + 1) % count
	return idx
