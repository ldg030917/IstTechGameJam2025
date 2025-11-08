extends Node2D

@export var cow_scene: Array[PackedScene]
@export var max_mob_count := 20

@export_group("Spawn Distance")
@export var min_spawn_radius: float = 800.0  # 최소 스폰 반경 (픽셀)
@export var max_spawn_radius: float = 2000.0 # 최대 스폰 반경 (픽셀)

@export_group("Spawn Attempts")
@export var spawn_attempts_per_tick: int = 10 # 타이머 틱당 스폰 시도 횟수

# --- 내부 변수 ---
@onready var spawn_timer = $Timer
var player: Player
var current_mob_count := 0

func _ready() -> void:
	#player = get_tree()
	pass

func on_mob_died():
	current_mob_count -= 1

func _on_spawn_timer_timeout():
	# 플레이어가 없거나 몹이 최대치에 도달하면 스폰 시도 안 함
	if not is_instance_valid(player) or current_mob_count >= max_mob_count:
		return
	for i in range(spawn_attempts_per_tick):
		var spawn_position = get_random_spawn_position()
	 # 2. 해당 위치가 스폰 가능한 곳인지 검사
		if is_valid_spawn_location(spawn_position):
			# 3. 검사를 통과하면 몹을 스폰하고 반복 종료
			spawn_mob(spawn_position)
			break # 이번 틱에서는 한 마리만 스폰
#TODO:개발

# 1. 랜덤 스폰 위치 후보 생성
func get_random_spawn_position() -> Vector2:
	var random_angle = randf_range(0, TAU) # 0 ~ 360도 사이의 랜덤 각도
	var random_radius = randf_range(min_spawn_radius, max_spawn_radius)
	var offset = Vector2.RIGHT.rotated(random_angle) * random_radius
	return player.global_position + offset

func is_valid_spawn_location(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = position
	parameters.collision_mask = null
	return true
	pass

func spawn_mob(a):
	pass
