extends PuzzleBlock

@export var open_delay := 0.5
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
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Delay(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])
	for lock in _opened_locks.values():
		if not lock:
			return

	_is_opened = true
	await get_tree().create_timer(open_delay).timeout
	if _is_opened:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Delay(%s) was opened." % [puzzle_name])
		on.emit(self)
	else:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Delay(%s) could not open." % [puzzle_name])


func _on_lock_closed(block: PuzzleBlock) -> void:
	if _opened_locks.has(block):
		_opened_locks[block] = false
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Delay(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])
	off.emit(self)
	_is_opened = false

func _get_mesh() -> MeshInstance3D:
	return null
