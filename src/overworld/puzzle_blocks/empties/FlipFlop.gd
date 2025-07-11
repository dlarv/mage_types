@tool
extends PuzzleBlock

@export var lock: PuzzleBlock


func _ready() -> void:
	super._ready()
	lock.on.connect(_on_lock_opened)


func _on_lock_opened(lock: PuzzleBlock) -> void:
	is_on = not is_on
	if is_on:
		on.emit(self)
	else:
		off.emit(self)


func _get_mesh() -> MeshInstance3D:
	return null
