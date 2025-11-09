extends Node2D

@export var main_scene = load("res://scene/Main.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
