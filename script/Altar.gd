extends Node2D

class_name Altar

@onready var hearts_array = [
	$Heart1,
	$Heart2,
	$Heart3
]
@onready var rage_effect = $RageEffect

@export var player: Player
var can_devote := false

@onready var devoting_sound = load("res://asset/audio/devoting.mp3")

func _ready() -> void:
	if is_instance_valid(player):
		player.devoted.connect(_on_player_devoted)

func _input(event: InputEvent) -> void:
	if can_devote and event.is_action_pressed("devote"):
		player.devote()
			
func _on_player_devoted(inventory: Array):
	var fade_in_duration = 1.5
	var sprite = $RageEffect/Rage
	
	sprite.scale = Vector2.ZERO
	rage_effect.show()
	
	var tween_in = create_tween()
	tween_in.tween_property(sprite, "scale", Vector2.ONE*3, fade_in_duration)

	for i in range(inventory.size()):
		hearts_array[i].show()
		
	await get_tree().create_timer(0.5).timeout
	
	Global.make_sound(devoting_sound,global_position, 0.0)
	$"../player".hp += $"../player".max_hp*30
	modulate = 1.4 * Color.WHITE
	
	for i in range(inventory.size()):
		Global.god_gauge += inventory[i]
		Global.god_gauge = clamp(Global.god_gauge, 0, Global.max_gg)
		hearts_array[i].hide()

	await tween_in.finished
	
	var fade_out_duration = 1.5
	
	var tween_out = create_tween()
	tween_out.tween_property(sprite, "scale", Vector2.ZERO, fade_out_duration)
	
	tween_out.tween_callback(rage_effect.hide)
func _physics_process(delta: float) -> void:
	z_index = global_position.y - 20
	
	modulate += 1.0 * (Color.WHITE - modulate)*delta
	

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$ColorRect.show()
		can_devote = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		$ColorRect.hide()
		can_devote = false
