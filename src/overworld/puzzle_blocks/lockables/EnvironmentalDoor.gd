extends Lockable

func _ready() -> void:
	super._ready()
	visible = not _is_locked


func _on_lock_opened(lock: PuzzleBlock) -> bool:
	if not super._on_lock_opened(lock): return false
	show()
	return true

func _on_lock_closed(lock: PuzzleBlock) -> bool:
	if not super._on_lock_closed(lock): return false
	hide()
	return true


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
