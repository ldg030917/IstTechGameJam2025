extends CharacterBody2D

@export var speed: float = 0
@export var hp: int = 10
@export var Dgg: float = 0.1 # Delta god gauge
@export var attack: int = 10
var state: State = State.IDLE
var target: Node2D

enum Type { HOSTILE, NEUTRAL, FRIENDLY }
enum State { IDLE, CHASE, ATTACK, STUN }


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			pass
		State.CHASE:
			var direction = global_position.direction_to(target.global_position)
			#print(direction)
			velocity = direction * speed
			#print(velocity)
	
	move_and_slide()




func _on_sight_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print("CHASE")
		target = body
		state = State.CHASE
		pass

func _on_chasing_area_body_exited(body: Node2D) -> void:
	if body is Player:
		state = State.IDLE

func hurt():
	pass
