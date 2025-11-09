extends Node2D

@onready var player = $player
@onready var game_over_screen = $GameOverScreen
@onready var timer = $Timer

func _ready() -> void:
	player.died.connect(_on_player_died)
	
func _on_player_died():
	await timer.on_game_over()
	game_over_screen.show()
	get_tree().paused = true
