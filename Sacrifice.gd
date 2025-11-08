extends CharacterBody2D

class_name Sacrifice

@onready var idle_action_timer = $IdleActionTimer
@onready var animation_sprite = $AnimatedSprite2D

@export var speed: float = 100
@export var hp: float = 10
@export var Dgg: float = 0.1 # Delta god gauge
@export var attack: float = 1.2
@export var type: Type = Type.HOSTILE

var state: State = State.IDLE
var target: Node2D
# 배회 로직
var is_wandering = false
var wander_target_position = Vector2.ZERO

# 1은 오른쪽 -1은 왼쪽
var facing_left := true

enum Type { HOSTILE, NEUTRAL, FRIENDLY }
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }

func _ready() -> void:
	state = State.IDLE
	_on_idle_action_timer_timeout()

func _physics_process(delta: float) -> void:
	$Label.text = str(state)
	z_index = global_position.y
	match state:
		State.IDLE:
			idle_state_logic(delta)
			pass
		State.CHASE:
			chase_state_logic()
		State.HURT:
			hurt_state_logic()
		_:
			velocity = Vector2.ZERO
			
	facing_left = true if velocity.x < 0 else false
		
	move_and_slide()

func idle_state_logic(delta):
	if is_wandering:
		var direction = (wander_target_position - global_position).normalized()
		velocity = velocity.move_toward(direction * speed, 20 * delta)
		if facing_left:
			animation_sprite.play("move_L")
		else:
			animation_sprite.play("move_R")
		if global_position.distance_to(wander_target_position) < 10:
			is_wandering = false
			velocity = Vector2.ZERO
	else:
		if facing_left:
			animation_sprite.play("idle_L")
		else:
			animation_sprite.play("idle_R")

func chase_state_logic():
	var direction = global_position.direction_to(target.global_position)
	velocity = direction * speed

func attack_state_logic(delta):
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
		$ChasingSprite.show()

func _on_chase_area_body_exited(body: Node2D) -> void:
	if body is Player and state != State.DEAD:
		state = State.IDLE
		$ChasingSprite.hide()

func hurt(damage: int):
	if state == State.DEAD:
		return
		
	state = State.HURT
	hp -= damage
	
	#print("hurt")
	if hp <= 0:
		state = State.DEAD
		$SightArea/CollisionShape2D.disabled = true
		$ChaseArea/CollisionShape2D.disabled = true
		$HeartPopArea/CollisionShape2D.disabled = false
		$ChasingSprite.hide()
		if facing_left:
			animation_sprite.play("dead_L")
		else:
			animation_sprite.play("dead_R")
		self_modulate.a = 0.5

func _on_idle_action_timer_timeout() -> void:
	var random_chance = randf()
	if random_chance < 0.7:
		is_wandering = true
		var random_offset = Vector2(randf_range(-150, 150), randf_range(-150, 150))
		wander_target_position = global_position + random_offset
	else:
		is_wandering = false
		
	idle_action_timer.start(randf_range(2.0, 5.0))


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.DEAD:
		return
	if animation_sprite.animation == "hurt_L" or animation_sprite.animation == "hurt_R":
		state = State.CHASE
		if type == Type.FRIENDLY:
			state = State.IDLE
