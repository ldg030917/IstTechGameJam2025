extends CanvasLayer

@onready var sight : ColorRect = $ColorRect

@export var min_radius : float = 0.1
@export var max_radius : float = 1.0
@export var change_step : float = 0.1

func _process(delta):
	if Input.is_action_just_pressed("up"):
		var current_radius = sight.material.get_shader_parameter("radius")
		var new_radius = current_radius - change_step
		new_radius = max(new_radius, min_radius) 
		sight.material.set_shader_parameter("radius", new_radius)

	if Input.is_action_just_pressed("down"):
		var current_radius = sight.material.get_shader_parameter("radius")
		var new_radius = current_radius + change_step
		new_radius = min(new_radius, max_radius)
		sight.material.set_shader_parameter("radius", new_radius)

func set_field_of_view(new_radius: float):
	new_radius = clamp(new_radius, min_radius, max_radius)
	sight.material.set_shader_parameter("radius", new_radius)
