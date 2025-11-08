extends CharacterBody2D

class_name Player

const inventory_size:int = 3

var hp:float
var speed:float
var atk:float
var inventory

var ref_pos:Vector2 = Vector2.ZERO

func reset(_hp = null, _speed = null, _atk = null, _pos_0 = null):
	hp = _hp
	speed = _speed
	atk = _atk
	inventory = []
	position = _pos_0
	ref_pos = _pos_0
	
func be_attacked(delta_hp:float):
	hp -= delta_hp
	#여기에 피격시 발생할 일들 추가
	
func attack(target):
	target.be_attacked(atk)
	#여기에 공격시 발생할 일들 추가

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
	_set_ref_pos(dt)
	_goto_ref_pos(dt)
