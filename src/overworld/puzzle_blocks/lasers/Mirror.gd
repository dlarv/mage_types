@tool
extends PuzzleBlock

func _on_rotated(obj:Node3D, player:Node3D) -> void:
	rotation_degrees.y += 90

