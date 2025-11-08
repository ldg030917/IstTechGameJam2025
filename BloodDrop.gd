extends RigidBody2D

@export var blood_puddle_scene : PackedScene
@export var sprite_rotation_offset_degrees : float = 0.0
@export var puddle_merge_radius: float = 30.0

var min_y_death : float
var max_y_death : float
var target_y_death : float

func _ready():
	if get_parent() and get_parent().get_parent():
		if get_parent().get_parent() is PhysicsBody2D:
			var parent = get_parent().get_parent()
			linear_velocity += Vector2.RIGHT * (parent.ref_pos - parent.global_position) * 2
	$Timer.timeout.connect(queue_free)
	target_y_death = randf_range(global_position.y + min_y_death, global_position.y + max_y_death)


func _physics_process(delta):
	if linear_velocity.length() > 0.1:
		$Sprite2D.rotation = linear_velocity.angle()
		$Sprite2D.rotation_degrees += sprite_rotation_offset_degrees

	if global_position.y >= target_y_death:
		var merge_puddle = find_nearby_puddle(global_position)
		
		if is_instance_valid(merge_puddle):
			merge_puddle.reset_duration_and_grow()
		else:
			if blood_puddle_scene:
				var puddle = blood_puddle_scene.instantiate()
				get_tree().get_root().add_child(puddle)
				puddle.global_position = Vector2(global_position.x, target_y_death)
		
		queue_free()

func find_nearby_puddle(pos: Vector2) -> Node2D:
	var puddles = get_tree().get_nodes_in_group("blood_puddles")
	var closest_puddle = null
	var min_dist_sq = puddle_merge_radius * puddle_merge_radius

	for p in puddles:
		if not is_instance_valid(p):
			continue
		
		var dist_sq = pos.distance_squared_to(p.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_puddle = p
	
	return closest_puddle
