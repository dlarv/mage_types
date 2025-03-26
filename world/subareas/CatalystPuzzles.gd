extends Chunk

@export var emitter: PuzzleBlock
@export var west_wall: Node3D


func _on_laser_receiver_off(node:PuzzleBlock) -> void:
	west_wall.hide()
	Logger.append_log(Logger.LogType.PUZZLE, "Catalyst alt solution closed.")

func _on_laser_receiver_on(node:PuzzleBlock) -> void:
	if emitter.laser.rand_val == node._prev_val:
		west_wall.show()
		Logger.append_log(Logger.LogType.PUZZLE, "Catalyst alt solution opened.")
	else:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Catalyst alt solution could not be opened. Received laser with Hash(%d), but expected Emitter(%s) with Hash(%d)."
				% [node._prev_val, emitter.puzzle_name, emitter.laser.rand_val])

