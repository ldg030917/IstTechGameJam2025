extends Node2D

class_name Altar

@onready var hearts_array = [
	$Heart1,
	$Heart2,
	$Heart3
]

var player: Player = null

func _input(event: InputEvent) -> void:
	if player != null and event.is_action_pressed("devote"):
		var hearts = player.devote()
		for i in range(hearts.size()):
			hearts_array[i].show()
			
		
func _physics_process(delta: float) -> void:
	z_index = global_position.y - 20
	

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$ColorRect.show()
		player = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		$ColorRect.hide()
		player = null
