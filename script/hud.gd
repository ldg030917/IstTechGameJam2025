extends CanvasLayer

func _ready():
	$GGbar.max_value = Global.max_gg

func _physics_process(delta: float) -> void:
	$GGbar.value = Global.god_gauge
	print(Global.god_gauge)
