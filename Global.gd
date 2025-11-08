extends Node

# 1, 2, 3 단계까지 있음
var god_gauge: float = 0

const a := 0.01

func _process(delta: float) -> void:
	god_gauge += delta * a
