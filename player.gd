extends CharacterBody2D

class_name Player

const inventory_size:int = 3

var speed_0:float

var hp:float
var speed:float
var atk:float
var inventory
var direction

var orientation

var ref_pos:Vector2 = Vector2.ZERO

enum STATE {
	default,
	attacking,
	hurt,
	devoting
}
var state

@onready var attack_area = $Node2D/AttackArea
@onready var animated_sprite = $AnimatedSprite2D

func reset(_hp = null, _speed = null, _atk = null, _pos_0 = null):
	hp = _hp
	speed_0 = _speed
	speed = speed_0
	atk = _atk
	inventory = [1,2,2]
	position = _pos_0
	ref_pos = _pos_0
	state = STATE.default
	orientation = "right"
	
func hurt(delta_hp:float, subject_pos:Vector2):
	if state == STATE.hurt : return
	
	state = STATE.hurt
	hp -= delta_hp
	var dr_hat = (position - subject_pos).normalized()
	ref_pos = position + 100 * dr_hat
	if dr_hat.dot(Vector2.RIGHT) > 0 : orientation = "left"
	elif dr_hat.dot(Vector2.RIGHT) < 0: orientation = "right"
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
	
func devote():
	if len(inventory) == 0 : return 
	speed = 0
	state = STATE.devoting
	

func _physics_process(dt: float) -> void:
	print(Global.god_gauge)
	z_index = global_position.y
	
	if orientation == "left" : $Node2D.scale.x = -1
	elif orientation == "right" : $Node2D.scale.x = 1
	
	if state == STATE.default:
		$AnimatedSprite2D.position = Vector2.ZERO
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		_set_ref_pos(dt)
		_goto_ref_pos(dt)
		
		var dr = (ref_pos - position)
		
		if dr.dot(Vector2.RIGHT) > 10 : orientation = "right"
		elif dr.dot(Vector2.RIGHT) < -10: orientation = "left"
		
		if dr.length() > 20: animated_sprite.play("move_" + orientation)
		else: animated_sprite.play("idle_" + orientation)
		
		if Input.is_action_just_pressed("attack"): attack()
	#	if Input.is_action_just_pressed("devote"): hurt(100, Vector2(randf_range(-1, 1),randf_range(-1, 1)) + position)
		
	elif  state == STATE.attacking:
		$AnimatedSprite2D.position = 20 * _convert_orientation_to_num(orientation) * Vector2.RIGHT
		animated_sprite.play("attack_" + orientation)
		
	elif  state == STATE.hurt:
		animated_sprite.play("hurt_" + orientation)
		modulate.a = 0.5
		_goto_ref_pos(dt)
		var dr = (ref_pos - position)
		if dr.length() < 10 : state = STATE.default
		
	elif state == STATE.devoting:
		animated_sprite.play("devoting")
		
func _convert_orientation_to_num(_orientation):
	if _orientation == "left" : return -1
	elif _orientation == "right" : return 1
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_left" or animated_sprite.animation == "attack_right":
		state = STATE.default
		speed = speed_0
		
	if animated_sprite.animation == "devoting":
		#print(inventory)
		for heart in inventory:
			Global.god_gauge -= heart
			
		inventory = []
		#print(inventory)
		
		state = STATE.default
		speed = speed_0
