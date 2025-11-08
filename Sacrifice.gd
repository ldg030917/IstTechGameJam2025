extends CharacterBody2D

@export var speed: int
@export var hp: int
@export var Dgg: float # Delta god gauge
@export var attack: int

func _process(delta: float) -> void:
	pass





func _on_sight_area_body_entered(body: Node2D) -> void:
	if body is Player:
		pass
