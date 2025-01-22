@tool
extends PuzzleBlock

@export var can_player_trigger: bool

func _on_body_entered(body: Node3D) -> void:
	if can_player_trigger and _test_for_player(body):
		_try_emit_on()
	elif body is MagiClay and body.element == element:
		_try_emit_on()


func _on_body_exited(body: Node3D) -> void:
	if (can_player_trigger and _test_for_player(body)) or body is MagiClay:
		_try_emit_off()


func _test_for_player(body: Node3D) -> bool:
	return element == ElementManager.Blank and body.is_in_group("player")
