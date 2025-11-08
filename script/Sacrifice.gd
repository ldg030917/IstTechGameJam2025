extends CharacterBody2D

class_name Sacrifice

@onready var idle_action_timer = $IdleActionTimer
@onready var animation_sprite = $AnimatedSprite2D
@onready var chasing_sprite = $ChasingSprite
var blooddrop_burst = load("res://scene/BloodDrop_Burst.tscn")

@export var speed: float = 100
@export var chase_speed: float = 100
@export var hp: float = 10
@export var dgg: float = 0.1 # Delta god gauge
@export var attack: float = 1.2
@export var type: Type = Type.HOSTILE

var state: State = State.IDLE
var target: Node2D
# 배회 로직
var is_wandering = false
var wander_target_position = Vector2.ZERO

# 1은 오른쪽 -1은 왼쪽
var facing_left := true
var player :Player = null

enum Type { HOSTILE, NEUTRAL, FRIENDLY }
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }

func _ready() -> void:
	state = State.IDLE
	_on_idle_action_timer_timeout()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("devote") and player != null:
		player.get_heart(dgg)
		player = null
		print("Get heart")
		if facing_left:
			animation_sprite.play("heartpop_L")
		else:
			animation_sprite.play("heartpop_R")

func _physics_process(delta: float) -> void:
	$Label.text = str(state)
	z_index = global_position.y
	match state:
		State.IDLE:
			idle_state_logic(delta)
			pass
		State.CHASE:
			chase_state_logic(delta)
		State.ATTACK:
			attack_state_logic(delta)
		State.HURT:
			hurt_state_logic()
		_:
			velocity = Vector2.ZERO
			
	facing_left = true if velocity.x < 0 else (facing_left if velocity.x == 0 else false)
		
	move_and_slide()

func idle_state_logic(delta):
	if is_wandering:
		var direction = (wander_target_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, 1 * delta)
		if facing_left:
			animation_sprite.play("move_L")
		else:
			animation_sprite.play("move_R")
		if global_position.distance_to(wander_target_position) < 10:
			is_wandering = false
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		if facing_left:
			animation_sprite.play("idle_L")
		else:
			animation_sprite.play("idle_R")

func chase_state_logic(delta):
	var direction = global_position.direction_to(target.global_position)
	var target_velocity = direction * chase_speed
	velocity = velocity.lerp(target_velocity, 1.5 * delta)
	
	if facing_left:
		animation_sprite.play("move_L")
	else:
		animation_sprite.play("move_R")

func attack_state_logic(delta):
	velocity = Vector2.ZERO
	if facing_left:
		animation_sprite.play("attack_L")
	else:
		animation_sprite.play("attack_R")
	
	pass

func hurt_state_logic():
	if facing_left:
		animation_sprite.play("hurt_L")
	else:
		animation_sprite.play("hurt_R")

func _on_sight_area_body_entered(body: Node2D) -> void:
	if type == Type.FRIENDLY:
		return
	if body is Player:
		print("CHASE")
		target = body
		if type == Type.NEUTRAL:
			return
		state = State.CHASE
		chasing_sprite.show()

func _on_chase_area_body_exited(body: Node2D) -> void:
	if body is Player and state != State.DEAD:
		state = State.IDLE
		is_wandering = false
		chasing_sprite.hide()

func hurt(damage: int, subject_pos: Vector2):
	if state == State.DEAD:
		return
		
	state = State.HURT
	hp -= damage
	var dr_hat = (position - subject_pos).normalized()
	velocity += dr_hat * 100
	var blooddrop_burst_scene = blooddrop_burst.instantiate()
	add_child(blooddrop_burst_scene)
	
	#print("hurt")
	if hp <= 0:
		state = State.DEAD
		$SightArea/CollisionShape2D.disabled = true
		$ChaseArea/CollisionShape2D.disabled = true
		$HeartPopArea/CollisionShape2D.disabled = false
		chasing_sprite.hide()
		#animation_sprite.modulate = Color.AQUA
		animation_sprite.position.y += 20
		if facing_left:
			animation_sprite.play("dead_L")
		else:
			animation_sprite.play("dead_R")

func _on_idle_action_timer_timeout() -> void:
	var random_chance = randf()
	if random_chance < 0.7:
		is_wandering = true
		var random_offset = Vector2(randf_range(-150, 150), randf_range(-150, 150))
		wander_target_position = global_position + random_offset
	else:
		is_wandering = false
		
	idle_action_timer.start(randf_range(3.0, 6.0))


func _on_animated_sprite_2d_animation_finished() -> void:
	match state:
		State.DEAD:
			return
		State.HURT:
			state = State.CHASE
			if type == Type.FRIENDLY:
				state = State.IDLE
		State.ATTACK:
			state = State.CHASE
			if type == Type.FRIENDLY:
				state = State.IDLE


func _on_heart_pop_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		#animation_sprite.modulate = Color.RED
		


func _on_heart_pop_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt(attack, position)
		state = State.ATTACK
