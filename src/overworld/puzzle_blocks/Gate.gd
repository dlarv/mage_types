extends StaticBody3D

## The number of PuzzleBlocks that must emit the on signal for this gate to open.
@export var locks: Array[PuzzleBlock]
## Once this gate has been opened, can it close again?
@export var permanent: bool
var _is_opened: bool
var _opened_locks := {}

func _ready() -> void:
	_is_opened = false
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)

func _on_lock_opened(block: PuzzleBlock) -> void:
	if _is_opened and permanent: return
	if not _opened_locks.get(block):
		_opened_locks[block] = true
		_open()

func _on_lock_closed(block: PuzzleBlock) -> void:
	if _is_opened and permanent: return
	if _opened_locks.has(block):
		print("lock closed")
		_opened_locks[block] = false
		_close()

func _open():
	for openedLock in _opened_locks.values():
		if not openedLock: return
	collision_layer = 0
	$AnimationPlayer.play("opening")
	_is_opened = true

func _close():
	collision_layer = 1
	$AnimationPlayer.play_backwards("opening")
	_is_opened = false 

