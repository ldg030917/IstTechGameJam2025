extends CanvasLayer

@export var player: Player
@onready var heart_icons = [
	$HBoxContainer/TextureRect,
	$HBoxContainer/TextureRect2,
	$HBoxContainer/TextureRect3
]

func _ready():
	$GGbar.max_value = Global.max_gg
	player.got_heart.connect(_on_player_got_heart)

func _physics_process(delta: float) -> void:
	$GGbar.value = Global.god_gauge
	print(Global.god_gauge)

func _on_player_got_heart(i):
	print(i)
	heart_icons[i].show()
	if i == -1:
		heart_icons[0].hide()
		heart_icons[1].hide()
		heart_icons[2].hide()
