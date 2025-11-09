extends Node

# 1, 2, 3 단계까지 있음
var god_gauge: float = 0
var max_gg:float = 100

const a := 1

func _ready() -> void:
	god_gauge = max_gg

func _process(delta: float) -> void:
	god_gauge -= delta * a

func make_sound(_sound,_pos:Vector2, _db, _offset = null):
	var s = Sound.new()
	s.stream = _sound
	s.volume_db = _db
	s.global_position = _pos
	add_child(s)
	var offset = 0 if _offset == null else _offset
	s.play(offset)
