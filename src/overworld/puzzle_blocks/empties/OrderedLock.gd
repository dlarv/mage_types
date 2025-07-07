@tool
extends PuzzleBlock
## Requires locks to be opened in a specific order.

@export var locks: Array[PuzzleBlock]

var _opened_locks := []


func _ready() -> void:
	for lock in locks:
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)
		lock.invalid_off.connect(_on_lock_closed)


func _on_lock_opened(lock: PuzzleBlock) -> void:
	if lock in _opened_locks:
		_opened_locks.remove_at(_opened_locks.find(lock))
	_opened_locks.append(lock)

	if len(_opened_locks) != len(locks): 
		off.emit(self)
		return

	for i in len(locks):
		if locks[i] != _opened_locks[i]:
			invalid_off.emit(self)
			return
	on.emit(self)


func _on_lock_closed(lock: PuzzleBlock) -> void:
	if lock in _opened_locks:
		_opened_locks.remove_at(_opened_locks.find(lock))
	off.emit(self)


