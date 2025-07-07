@tool
extends PuzzleBlock

@export var toggle_mode := false


func _on_interactable_interacted(obj: Node3D) -> void:
	is_on = not is_on

	if not toggle_mode or is_on:
		on.emit(self)
	else:
		off.emit(self)

