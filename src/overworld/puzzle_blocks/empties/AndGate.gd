extends PuzzleBlock

## The number of PuzzleBlocks that must emit the on signal for this gate to open.
@export var locks: Array[PuzzleBlock]

var _is_locked := true
var _opened_locks := {}

func _ready() -> void:
	super._ready()
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)

## Returns true if door should close.
func _on_lock_closed(lock: PuzzleBlock) -> bool: 
	if _opened_locks.has(lock):
		_opened_locks[lock] = false
		_is_locked = true
		Logger.append_puzzle_log("AndGate(%s)'s Lock(%s) was closed." % [puzzle_name, lock.puzzle_name])
		off.emit(self)
		return true
	return false


## Returns true if door should open.
func _on_lock_opened(lock: PuzzleBlock) -> bool: 
	if _opened_locks.has(lock):
		_opened_locks[lock] = true
		Logger.append_puzzle_log("AndGate(%s)'s Lock(%s) was opened." % [puzzle_name, lock.puzzle_name])
	else:
		return false

	for val in _opened_locks.values():
		if not val: return false
	_is_locked = false
	on.emit(self)
	return true
