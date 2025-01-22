@tool
extends MagiClay
class_name PuzzleBlock

signal on(node: PuzzleBlock)
signal off(node: PuzzleBlock)

@export var is_on := false

func _try_emit_on():
	if not in_stasis and not is_on:
		on.emit(self)
		is_on = true

func _try_emit_off():
	if not in_stasis and is_on:
		off.emit(self)
		is_on = false 
