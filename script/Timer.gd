extends Control

var start_time_ms
@onready var label = $Label

func _ready() -> void:
	start_time_ms = Time.get_ticks_msec()
	
func _process(delta: float) -> void:
	calc_time()

func calc_time():
	var cur_time_ms = Time.get_ticks_msec()
	var elapsed_seconds = (cur_time_ms - start_time_ms) / 1000.0
	label.text = str(elapsed_seconds)
