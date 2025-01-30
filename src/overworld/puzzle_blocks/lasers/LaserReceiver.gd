extends PuzzleBlock


func _on_body_entered(body:Node3D) -> void:
	if body.get_collision_layer_value(5): 
		body.queue_free()

		if element.is_blank() or body.element == element:
			_try_emit_on()

