extends Node2D

@export var player_node : Player

const TILE_SIZE = Vector2(1206, 728)
const TILE_SCENE = preload("res://scene/BackgroundTile.tscn")

var player: Node2D = null
var tiles = {}

var current_center_cell = Vector2i.MAX 

func _ready():
	if player_node and player_node is Player:
		player = player_node
	else:
		set_physics_process(false)
		return

	_update_tile_positions(true)

func _physics_process(delta):
	if not player:
		return
	
	_update_tile_positions(false)

func _update_tile_positions(force_update: bool):
	var player_cell = (player.global_position / TILE_SIZE).floor()
	var player_cell_int = Vector2i(player_cell)

	if player_cell_int != current_center_cell or force_update:
		current_center_cell = player_cell_int
		
		var keys_to_remove = []
		for cell_coord in tiles.keys():
			if abs(cell_coord.x - current_center_cell.x) > 2 or \
			   abs(cell_coord.y - current_center_cell.y) > 2:
				keys_to_remove.append(cell_coord)
		
		for key in keys_to_remove:
			var tile_to_remove = tiles[key]
			tiles.erase(key)
			tile_to_remove.queue_free()

		for y in range(-2, 3):
			for x in range(-2, 3):
				var cell_offset = Vector2i(x, y)
				var target_cell = current_center_cell + cell_offset
				
				if not tiles.has(target_cell):
					var new_tile = TILE_SCENE.instantiate()
					add_child(new_tile)
					
					var target_position = Vector2(target_cell) * TILE_SIZE
					new_tile.global_position = target_position
					
					tiles[target_cell] = new_tile
