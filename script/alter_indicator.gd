extends Sprite2D

@export var altar: Altar
@export var player: Player

@export var min_visible_distance: float = 1000.0
@export var display_radius: float = 400.0
@export var arrow_rotation_offset_degrees: float = 90.0

var screen_center: Vector2

func _ready():
	visible = false
	_update_screen_center()
	get_viewport().size_changed.connect(_update_screen_center)

func _update_screen_center():
	screen_center = get_viewport_rect().size / 2.0

func _process(delta):
	if not is_instance_valid(altar) or not is_instance_valid(player):
		visible = false
		return
	
	var altar_pos = altar.global_position
	var player_pos = player.global_position
	
	var direction_vector = altar_pos - player_pos
	var distance = direction_vector.length()
	
	if distance < min_visible_distance:
		visible = false
		return
	
	visible = true
	
	var normalized_direction = direction_vector.normalized()
	self.global_position = screen_center + normalized_direction * display_radius
	self.rotation = direction_vector.angle() + deg_to_rad(arrow_rotation_offset_degrees)
