extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var stay_duration: float = 3.0
@export var fade_duration: float = 2.0
@export var time_gain_on_hit: float = 0.5

@export var base_scale: float = 0.5
@export var max_scale: float = 2.5
@export var merge_radius: float = 30.0

var hit_count: int = 1

var total_lifetime: float
var current_lifetime: float

func _ready():
	add_to_group("blood_puddles")
	sprite.scale = Vector2(base_scale, base_scale)
	
	total_lifetime = stay_duration + fade_duration
	current_lifetime = total_lifetime
	sprite.modulate.a = 1.0

func _process(delta):
	current_lifetime -= delta
	
	if current_lifetime <= 0:
		queue_free()
		return

	if current_lifetime <= fade_duration:
		sprite.modulate.a = current_lifetime / fade_duration
	else:
		sprite.modulate.a = 1.0

func reset_duration_and_grow():
	current_lifetime += time_gain_on_hit
	current_lifetime = min(current_lifetime, total_lifetime)
	
	hit_count += 1
	
	var merge_radius_sq = merge_radius * merge_radius
	var puddles = get_tree().get_nodes_in_group("blood_puddles")
	
	for p in puddles:
		if p == self or not is_instance_valid(p):
			continue
		
		if global_position.distance_squared_to(p.global_position) < merge_radius_sq:
			p.queue_free()
	
	var new_scale_val = min(base_scale * sqrt(hit_count), max_scale)
	var target_scale = Vector2(new_scale_val, new_scale_val)
	merge_radius *= new_scale_val / base_scale
	
	var scale_tween = create_tween().set_parallel()
	scale_tween.tween_property(sprite, "scale", target_scale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func get_hit_count() -> int:
	return hit_count
