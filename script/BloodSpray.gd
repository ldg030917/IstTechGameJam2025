extends Node2D
var blood_drop_scene  = load("res://scene/BloodDrop.tscn")

enum Mode { ONE_SHOT, CONTINUOUS }
@export var mode : Mode = Mode.ONE_SHOT

@export var amount : int
@export var lifetime : float = 0.0
@export var speed_min : float = 150.0
@export var speed_max : float = 300.0
@export var base_direction_degrees : float = -90.0
@export var spread_degrees : float = 180.0
@export var min_y_death : float = 150.0
@export var max_y_death : float = 250.0
@export var time_randomness : float = 0.5

var has_fired : bool = false
var time_active : float = 0.0
var emission_timer : float = 0.0

func _ready():
	get_parent().wrap()
	if mode == Mode.ONE_SHOT:
		fire()

func _process(delta):
	if mode == Mode.CONTINUOUS:
		time_active += delta
		if lifetime > 0.0 and time_active > lifetime:
			queue_free()
			return
		
		emission_timer -= delta
		
		while emission_timer <= 0:
			spawn_drop()
			# 다음 스폰까지의 랜덤한 시간을 계산해서 (음수가 된) 타이머에 더함
			emission_timer += _get_random_delay()

func _get_random_delay() -> float:
	# 1. 기본 딜레이 계산 (amount가 10이면 0.1초)
	var base_delay = 1.0 / float(amount)
	if base_delay <= 0.0: 
		base_delay = 0.001 # 0으로 나누기 방지

	# 2. 랜덤 오프셋 계산 (randomness가 0.5면 딜레이의 +-50%)
	var offset = base_delay * time_randomness
	
	# 3. 최종 딜레이 계산 (무한 루프 방지를 위해 0.001초보다 작아지지 않게 함)
	var next_delay = randf_range(max(0.001, base_delay - offset), base_delay + offset)
	
	return next_delay

func fire():
	if has_fired: return
	has_fired = true
	
	for i in amount:
		spawn_drop()
	
	queue_free()

func spawn_drop():
	if not blood_drop_scene:
		return

	var drop = blood_drop_scene.instantiate()
	drop.min_y_death = min_y_death
	drop.max_y_death = max_y_death
	get_parent().add_child.call_deferred(drop)
	
	
	var speed = randf_range(speed_min, speed_max)
	var angle_rad : float
	
	var base_rad : float
	var spread_rad = deg_to_rad(spread_degrees / 2.0)

	base_rad = deg_to_rad(90.0)

	angle_rad = randf_range(base_rad - spread_rad, base_rad + spread_rad)
	
	var direction_vector = Vector2.RIGHT.rotated(angle_rad)
	
	if "linear_velocity" in drop:
		drop.linear_velocity = direction_vector * speed
