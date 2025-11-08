extends RigidBody2D

@export var blood_puddle_scene : PackedScene
@export var sprite_rotation_offset_degrees : float = 0.0

var min_y_death : float
var max_y_death : float 

var target_y_death : float

func _ready():
	$Timer.timeout.connect(queue_free)
	target_y_death = randf_range(min_y_death, max_y_death)

func _physics_process(delta):
	if linear_velocity.length() > 0.1:
		$Sprite2D.rotation = linear_velocity.angle()
		$Sprite2D.rotation_degrees += sprite_rotation_offset_degrees

	if global_position.y >= target_y_death:
		if blood_puddle_scene:
			var puddle = blood_puddle_scene.instantiate()
			if get_parent():
				get_parent().add_child(puddle)
				puddle.global_position = Vector2(global_position.x, target_y_death)
		
		queue_free()
