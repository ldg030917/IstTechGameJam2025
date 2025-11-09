extends AudioStreamPlayer2D

class_name Sound

func _on_finished() -> void:
	queue_free()
