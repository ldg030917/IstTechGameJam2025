extends CanvasLayer

@onready var sight : ColorRect = $ColorRect

@export var min_radius : float = 0.1
@export var max_radius : float = 1.0
@export var change_step : float = 0.1
@export var player : Player

var is_dead := false

func _ready():
	if player:
		player.died.connect(_on_player_dead)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	make_darker((Global.god_gauge/Global.max_gg) - 0.3)
	
func make_darker(_r:float):
	var current_radius = sight.material.get_shader_parameter("radius")
	var new_radius = _r
	new_radius = min(new_radius, max_radius)
	sight.material.set_shader_parameter("radius", new_radius)

func _on_player_dead():
	is_dead = true
	var tween = create_tween()
	tween.tween_property(sight.material, "shader_parameter/radius", -0.6, 2.0)
