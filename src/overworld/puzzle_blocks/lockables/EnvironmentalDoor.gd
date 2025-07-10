extends Lockable

@export var visible_when_open := true

func _ready() -> void:
	super._ready()
	visible = bool(int(_is_locked) ^ int(visible_when_open))


func _on_lock_opened(lock: PuzzleBlock) -> bool:
	if not super._on_lock_opened(lock): return false
	visible = visible_when_open
	return true


func _on_lock_closed(lock: PuzzleBlock) -> bool:
	if not super._on_lock_closed(lock): return false
	visible = not visible_when_open
	return true


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
