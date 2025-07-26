@tool
extends MagiClay
class_name PuzzleBlock

const Laser := preload("res://src/overworld/puzzle_blocks/lasers/components/Laser.gd")

signal on(node: PuzzleBlock)
signal off(node: PuzzleBlock)
@warning_ignore("UNUSED_SIGNAL")
signal invalid_off(node: PuzzleBlock)

@export var is_on := true:
	set(val):
		is_on = val
		if val:
			start()
		else:
			stop()

func _enter_tree() -> void:
	super._enter_tree()

func start(val: Variant=null) -> void: pass
func stop(val: Variant=null) -> void: pass

func _try_emit_on() -> bool:
	if not in_stasis and not is_on:
		on.emit(self)
		is_on = true
		return true
	return false

func _try_emit_off() -> bool:
	if not in_stasis and is_on:
		off.emit(self)
		is_on = false 
		return true
	return false
