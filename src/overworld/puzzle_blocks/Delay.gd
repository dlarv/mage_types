extends PuzzleBlock

@export var time_length := 0.5
@export var locks: Array[PuzzleBlock]

var _opened_locks := {}
var _is_opened := false

func _ready() -> void:
	_is_opened = false
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)

func _on_lock_opened(block: PuzzleBlock) -> void:
	if not _opened_locks.get(block):
		_opened_locks[block] = true
	for lock in _opened_locks.values():
		if not lock:
			return

	_is_opened = true
	await get_tree().create_timer(time_length).timeout
	if _is_opened:
		on.emit(self)


func _on_lock_closed(block: PuzzleBlock) -> void:
	if _opened_locks.has(block):
		_opened_locks[block] = false
	off.emit()
	_is_opened = false
