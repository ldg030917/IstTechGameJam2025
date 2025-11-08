extends CharacterBody2D

class_name Player

const inventory_size:int = 3

var speed_0:float

var hp:float
var speed:float
var atk:float
var inventory

var ref_pos:Vector2 = Vector2.ZERO

enum STATE {
	default,
	attacking,
	being_attacked,
	devoting
}
var state

@onready var attack_area = $sprite/AttackArea
@onready var animated_sprite = $sprite/AnimatedSprite2D

func reset(_hp = null, _speed = null, _atk = null, _pos_0 = null):
	hp = _hp
	speed_0 = _speed
	speed = speed_0
	atk = _atk
	inventory = []
	position = _pos_0
	ref_pos = _pos_0
	state = STATE.default
	
func be_attacked(delta_hp:float):
	hp -= delta_hp
	#여기에 피격시 발생할 일들 추가
	
func attack():
	state = STATE.attacking
	
	speed = 0
	
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	#print(overlapping_bodies)
	# 2. 겹친 바디들을 하나씩 순회합니다.
	for body in overlapping_bodies:
		if body is Sacrifice:
			body.hurt(atk)
		# 3. 이 바디가 "적"(enemy)인지 확인합니다. (그룹 사용을 추천)
		#(적 씬에서 "enemy" 그룹에 추가해두어야 함)      
		# 4. 적에게 "take_damage" 함수가 있다면 호출하여 대미지를 줍니다.

func _set_ref_pos(dt:float):
	if Input.is_action_pressed("up"): ref_pos += dt*speed*Vector2.UP
	if Input.is_action_pressed("down"): ref_pos += dt*speed*Vector2.DOWN
	if Input.is_action_pressed("left"): ref_pos += dt*speed*Vector2.LEFT
	if Input.is_action_pressed("right"): ref_pos += dt*speed*Vector2.RIGHT

func _goto_ref_pos(dt:float):
	const k = 5.0
	position += k*(ref_pos - position)*dt
	
func _ready() -> void:
	reset(100, 500, 1, Vector2.ZERO)

func _physics_process(dt: float) -> void:
	if state == STATE.default:
		if Input.is_action_just_pressed("attack"): attack()
		_set_ref_pos(dt)
		_goto_ref_pos(dt)
		
		var dr = (ref_pos - position)
		
		if dr.length() > 20: animated_sprite.play("walk")
		else: animated_sprite.play("idle")
		
		if dr.dot(Vector2.RIGHT) > 1 : scale.x = 1
		elif dr.dot(Vector2.RIGHT) < -1: scale.x = -1
		
	elif  state == STATE.attacking:
		animated_sprite.play("attack")
	elif  state == STATE.being_attacked:
		pass
	elif state == STATE.devoting:
		pass
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack": 
		state = STATE.default
		speed = speed_0
