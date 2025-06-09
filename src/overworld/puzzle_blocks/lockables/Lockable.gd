extends Node3D
class_name Lockable

signal on(node: PuzzleBlock)
signal off(node: PuzzleBlock)

## The number of PuzzleBlocks that must emit the on signal for this gate to open.
@export var locks: Array[PuzzleBlock]
## Once this gate has been opened, can it close again?
@export var permanent: bool

var puzzle_name:
	get():
		if get_parent() == null:
			return "%s" % name
		return "%s.%s" % [get_parent().name, name]

var _is_locked := true
var _opened_locks := {}

func _ready() -> void:
	for lock in locks:
		if not lock: continue
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)

## Returns true if door should close.
func _on_lock_closed(lock: PuzzleBlock) -> bool: 
	if not _is_locked and permanent: return false

	if _opened_locks.has(lock):
		_opened_locks[lock] = false
		_is_locked = true
		Logger.append_puzzle_log("Lockable(%s)'s Lock(%s) was closed." % [puzzle_name, lock.puzzle_name])
		off.emit(self)
		return true
	return false


## Returns true if door should open.
func _on_lock_opened(lock: PuzzleBlock) -> bool: 
	if not _is_locked and permanent: return true

	if _opened_locks.has(lock):
		_opened_locks[lock] = true
		Logger.append_puzzle_log("Gate(%s)'s Lock(%s) was opened." % [puzzle_name, lock.puzzle_name])
	else:
		return false

	for val in _opened_locks.values():
		if not val: return false
	_is_locked = false
	on.emit(self)
	return true

func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"locked": _is_locked,
	}

func deserialize(data: Dictionary) -> void:
	_is_locked = data["locked"]
	if not data["locked"] and permanent:
		_on_lock_opened(null)
