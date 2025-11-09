extends Node2D

class_name Altar

@onready var hearts_array = [
	$Heart1,
	$Heart2,
	$Heart3
]

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
	for i in range(inventory.size()):
		hearts_array[i].show()
	await get_tree().create_timer(3.0).timeout
	Global.make_sound(devoting_sound,global_position, 0.0)
	modulate = 100 * Color.WHITE
	for i in range(inventory.size()):
		Global.god_gauge += inventory[i]
		Global.god_gauge = clamp(Global.god_gauge, 0, Global.max_gg)
		hearts_array[i].hide()
		
func _physics_process(delta: float) -> void:
	z_index = global_position.y - 20
	
	modulate += 20.0 * (Color.WHITE - modulate)*delta
	

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$ColorRect.show()
		can_devote = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		$ColorRect.hide()
		can_devote = false
