extends PuzzleBlock

@export var locks: Array[PuzzleBlock]

var _opened_locks := {}

func _ready() -> void:
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)


func _on_lock_closed(lock: PuzzleBlock) -> void:
	_opened_locks[lock] = false

	for opened in _opened_locks.values():
		if opened:
			_try_emit_on()
			return
	_try_emit_off()


func _on_lock_opened(lock: PuzzleBlock) -> void:
	_opened_locks[lock] = true

	for opened in _opened_locks.values():
		if opened:
			_try_emit_on()
			return
	_try_emit_off()
