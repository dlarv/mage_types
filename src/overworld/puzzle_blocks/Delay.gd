@tool
extends PuzzleBlock

@export var open_delay := 0.5:
	set(val):
		open_delay = val
@export var locks: Array[PuzzleBlock]

var _opened_locks := {}
var _is_opened := false

func _ready() -> void:
	super._ready()
	$AnimationPlayer.speed_scale = 60 / open_delay
	_is_opened = false
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)


func _on_lock_opened(block: PuzzleBlock) -> void:
	if not _opened_locks.get(block):
		_opened_locks[block] = true
		Logger.append_puzzle_log("Delay(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])

	for lock in _opened_locks.values():
		if not lock:
			return

	_is_opened = true
	$AnimationPlayer.play("turning")
	$Timer.start(open_delay)
	await $Timer.timeout
	if _is_opened:
		Logger.append_puzzle_log("Delay(%s) was opened." % [puzzle_name])
		on.emit(self)
	else:
		Logger.append_puzzle_log("Delay(%s) could not open." % [puzzle_name])
		off.emit(self)


func _on_lock_closed(block: PuzzleBlock) -> void:
	if _opened_locks.has(block):
		_opened_locks[block] = false
		Logger.append_puzzle_log("Delay(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])
	off.emit(self)
	_is_opened = false
	$Timer.stop()
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.speed_scale *= -6
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.speed_scale /= -6
		

func _get_mesh() -> MeshInstance3D:
	return null
