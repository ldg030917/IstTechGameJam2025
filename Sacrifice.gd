extends CharacterBody2D

class_name Sacrifice

@onready var wander_timer = $Wander
@onready var animation_player = $AnimationPlayer

@export var speed: float = 100
@export var hp: float = 5
@export var Dgg: float = 0.1 # Delta god gauge
@export var attack: float = 1
var state: State = State.IDLE
var target: Node2D

enum Type { HOSTILE, NEUTRAL, FRIENDLY }
enum State { IDLE, CHASE, ATTACK, STUN, DEAD }

func _ready() -> void:
	state = State.IDLE
	$Sprite2D/Label.text = str(hp)
	pass

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			pass
		State.CHASE:
			var direction = global_position.direction_to(target.global_position)
			velocity = direction * speed
		_:
			velocity = Vector2.ZERO
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

func hurt(damage: int):
	hp -= damage
	$Sprite2D/Label.text = str(hp)
	#print("hurt")
	$Sprite2D.self_modulate = Color.RED
	if hp <= 0:
		state = State.DEAD
		animation_player.play("death")
		self_modulate.a = 0.5

func _on_wander_timeout() -> void:
	pass # Replace with function body.
