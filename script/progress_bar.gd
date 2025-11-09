extends ProgressBar

func _ready() -> void:
	max_value = $"..".max_hp

func _physics_process(delta: float):
	value = $"..".hp
	
