extends Node2D

class_name Altar

var player: Player = null

func _input(event: InputEvent) -> void:
	if player != null and event.is_action_pressed("devote"):
		print(player.inventory)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$ColorRect.show()
		player = body


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		$ColorRect.hide()
		player = null
