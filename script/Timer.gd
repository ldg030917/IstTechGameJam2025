extends CanvasLayer

var start_time_ms
var is_shaking = false
var original_position = Vector2.ZERO
@onready var label = $Label

func _ready() -> void:
	start_time_ms = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if is_shaking:
		label.rotation_degrees = randf_range(-10, 10)
	calc_time()

func calc_time():
	var cur_time_ms = Time.get_ticks_msec()
	var elapsed_seconds = (cur_time_ms - start_time_ms) / 1000.0
	var minutes = int(elapsed_seconds) / 60
	var seconds = int(elapsed_seconds) % 60
	var centiseconds = int((elapsed_seconds - int(elapsed_seconds)) * 100)
	label.text = "%02d:%02d:%02d" % [minutes, seconds, centiseconds]

func on_game_over():
	var tween = create_tween()
	
	var target_font_size = get_viewport().size.y * 0.5
	tween.tween_property(label, "theme_override_font_sizes/font_size", target_font_size, 2.0)\
	.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await get_tree().create_timer(1).timeout
	
