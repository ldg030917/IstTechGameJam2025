extends Node

# 1, 2, 3 단계까지 있음
var god_gauge: float = 0
var max_gg:float = 100
var rage_threshold:float = 33

signal rage_mode_activated
signal rage_mode_deactivated
var rage_mode_active: bool = false

const a := 1

func set_gauge():
	god_gauge = max_gg
	check_cond()

func _process(delta: float) -> void:
	god_gauge -= delta * a
	check_cond()

func is_rage():
	return god_gauge <= rage_threshold

func check_cond():
	if god_gauge <= rage_threshold and not rage_mode_active:
		rage_mode_active = true
		rage_mode_activated.emit()
		print("emit")
	elif god_gauge > rage_threshold and rage_mode_active:
		rage_mode_active = false
		rage_mode_deactivated.emit()

func make_sound(_sound,_pos:Vector2, _db, _offset = null):
	var s = Sound.new()
	s.stream = _sound
	s.volume_db = _db
	s.global_position = _pos
	add_child(s)
	var offset = 0 if _offset == null else _offset
	s.play(offset)
