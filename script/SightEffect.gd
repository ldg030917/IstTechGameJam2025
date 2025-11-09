extends CanvasLayer

@onready var sight : ColorRect = $ColorRect

@export var min_radius : float = 0.1
@export var max_radius : float = 1.0
@export var change_step : float = 0.1
	
func _physics_process(delta: float) -> void:
	make_darker((Global.god_gauge/Global.max_gg) - 0.3)
	
func make_darker(_r:float):
	var current_radius = sight.material.get_shader_parameter("radius")
	var new_radius = _r
	new_radius = min(new_radius, max_radius)
	sight.material.set_shader_parameter("radius", new_radius)
