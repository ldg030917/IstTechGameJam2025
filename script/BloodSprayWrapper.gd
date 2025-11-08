extends Node2D

enum Mode { ONE_SHOT, CONTINUOUS }
@export var mode : Mode = Mode.ONE_SHOT

@export var amount : int = 7
@export var lifetime : float = 0.0
@export var speed_min : float = 200
@export var speed_max : float = 400
@export var base_direction_degrees : float = 0
@export var spread_degrees : float = 360
@export var min_y_death : float = 100
@export var max_y_death : float = 150
@export var time_randomness : float = 0.5

var spawner : Node2D

func wrap():
	spawner = get_child(0)
	if not spawner: return
	spawner.mode = mode
	spawner.amount = amount
	spawner.lifetime = lifetime
	spawner.speed_min = speed_min
	spawner.speed_max = speed_max
	spawner.base_direction_degrees = base_direction_degrees
	spawner.spread_degrees = spread_degrees
	spawner.time_randomness = time_randomness
	spawner.min_y_death = min_y_death
	spawner.max_y_death = max_y_death

func stop():
	if is_instance_valid(spawner):
		spawner.queue_free()

func _process(delta):
	if get_child_count() == 0:
		queue_free()
