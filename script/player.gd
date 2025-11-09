extends CharacterBody2D

class_name Player

const inventory_size:int = 3

var speed_0:float

var hp: float
var speed:float
var atk:float
var inventory: Array
var direction

var orientation

var ref_pos:Vector2 = Vector2.ZERO

enum STATE {
	default,
	attacking,
	hurt,
	devoting,
	poping
}
var state

signal hp_changed(current_hp)
var max_hp:float = 10.0
@onready var hp_bar: ProgressBar = $ProgressBar

var last_dgg:float = 0

signal devoted(inventory: Array[float])
signal died

@onready var attack_area = $Node2D/AttackArea
@onready var animated_sprite = $AnimatedSprite2D

@onready var attack_sound = load("res://asset/audio/swing.mp3")
@onready var penetrate_sound = load("res://asset/audio/penetrated.mp3")
@onready var heart_poping_sound = load("res://asset/audio/heart_pop.mp3")

func reset(_hp = null, _speed = null, _atk = null, _pos_0 = null):
	speed_0 = _speed
	speed = speed_0
	atk = _atk
	inventory = []
	position = _pos_0
	ref_pos = _pos_0
	state = STATE.default
	orientation = "right"

	# 5. 체력바의 최대값을 설정합니다.
	if hp_bar:
		hp_bar.max_value = max_hp
		
	print(max_hp)
	hp = max_hp # (set 함수가 호출되며 3, 4번이 실행됩니다)
	
func hurt(delta_hp:float, subject_pos:Vector2):
	
	if state == STATE.hurt : return
	state = STATE.hurt
	hp -= delta_hp
	var dr_hat = (position - subject_pos).normalized()
	ref_pos = position + 100 * dr_hat
	if dr_hat.dot(Vector2.RIGHT) > 0 : orientation = "left"
	elif dr_hat.dot(Vector2.RIGHT) < 0: orientation = "right"
	if hp <= 0:
		died.emit()
	
func attack():
	state = STATE.attacking
	speed = 0
	
	Global.make_sound(attack_sound,global_position, 13.0)
	
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	#print(overlapping_bodies)
	# 2. 겹친 바디들을 하나씩 순회합니다.
	for body in overlapping_bodies:
		if body is Sacrifice:
			if body.hurt(atk, position):
				Global.make_sound(penetrate_sound,global_position, 3.0)
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
	#position += k*(ref_pos - position)*dt
	var collision = move_and_collide(k*(ref_pos - position)*dt)
	if collision:
		ref_pos = position


func _ready() -> void:
	reset(100, 500, 1, Vector2.ZERO)
	
func devote() -> void:
	if len(inventory) == 0 : return
	speed = 0
	state = STATE.devoting
	
func get_heart(dgg):
	if inventory.size() >= 3:
		return
	last_dgg = dgg
	state = STATE.poping
	speed = 0
	Global.make_sound(heart_poping_sound, global_position, 0.0)

	

func _physics_process(dt: float) -> void:
	#print(Global.god_gauge)
	z_index = global_position.y + 40
	
	if orientation == "left" : $Node2D.scale.x = -1
	elif orientation == "right" : $Node2D.scale.x = 1
	
	if state == STATE.default:
		$AnimatedSprite2D.position = Vector2.ZERO
		
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		#var direction = Input.get_vector("left", "right", "up", "down").normalized()
		#var target_velocity = direction * speed
		#velocity = velocity.ler
		_set_ref_pos(dt)
		_goto_ref_pos(dt)
		
		var dr = (ref_pos - position)
		
		if dr.dot(Vector2.RIGHT) > 10 : orientation = "right"
		elif dr.dot(Vector2.RIGHT) < -10: orientation = "left"
		
		if dr.length() > 20:
			animated_sprite.play("move_" + orientation)
			if $walk_sound.playing == false : $walk_sound.play()
		else: 
			animated_sprite.play("idle_" + orientation)
			$walk_sound.stop()
		
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
		
	elif state == STATE.poping:
		animated_sprite.play("heart_poping")
		
	if hp >= max_hp: hp = max_hp
	
func _convert_orientation_to_num(_orientation):
	if _orientation == "left" : return -1
	elif _orientation == "right" : return 1
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_left" or animated_sprite.animation == "attack_right":
		state = STATE.default
		speed = speed_0
		
	if animated_sprite.animation == "devoting":
		#print(inventory)
		devoted.emit(inventory)
		inventory = []
		#print(inventory)
		
		state = STATE.default
		speed = speed_0
		
	if animated_sprite.animation == "heart_poping":
		inventory.append(last_dgg)
		print(inventory)
		speed = speed_0
		state = STATE.default
		
	if animated_sprite.animation == "hurt_left" or animated_sprite.animation == "hurt_right":
		print("sadf")
		state = STATE.default
		speed = speed_0
