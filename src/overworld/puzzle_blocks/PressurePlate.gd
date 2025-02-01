@tool
extends PuzzleBlock

@export var can_player_trigger: bool

func _on_body_entered(body: Node3D) -> void:
	var bodyName: String
	var bodyElement: String
	if body.is_in_group("player"):
		bodyName = "Player"
		bodyElement = "n/a"
	else:
		bodyName = body.puzzle_name
		bodyElement = body.element.name

	if can_player_trigger and _test_for_player(body):
		_try_emit_on()
		Logger.append_log(Logger.LogType.PUZZLE, 
				"PressurePlate(%s) was activated by player." % [puzzle_name])
	elif body is MagiClay and body.element == element:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"PressurePlate(%s) was activated by MagiClay(%s)." % [puzzle_name, body.puzzle_name])

		_try_emit_on()
	else:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"PressurePlate(%s) was stepped on, but not activated, by Object(%s). Object is Element(%s), but plate requires Element(%s)." 
				% [puzzle_name, bodyName, bodyElement, element.name])

func _on_body_exited(body: Node3D) -> void:
	if (can_player_trigger and _test_for_player(body)) or body is MagiClay:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"PressurePlate(%s) was deactivated by MagiClay(%s)." % [puzzle_name, body.puzzle_name])
		_try_emit_off()


func _test_for_player(body: Node3D) -> bool:
	return element == ElementManager.Blank and body.is_in_group("player")
