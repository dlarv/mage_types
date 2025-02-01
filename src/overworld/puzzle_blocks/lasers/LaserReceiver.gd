extends PuzzleBlock


func _on_body_entered(body:Node3D) -> void:
	if body.get_collision_layer_value(5): 
		if element.is_blank() or body.element == element:
			_try_emit_on()
			Logger.append_log(Logger.LogType.PUZZLE, 
					"LaserReceiver(%s) hit by valid laser." % [puzzle_name])
		else:
			Logger.append_log(Logger.LogType.PUZZLE, 
					"LaserReceiver(%s) hit by invalid laser. Laser was Element(%s), but Receiver requires Element(%s)." % [puzzle_name, body.element.name, element.name])
		body.queue_free()

