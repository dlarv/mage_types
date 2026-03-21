@tool
extends PuzzleBlock

@export var open_delay := 0.5:
	set(val):
		open_delay = val
@export var locks: Array[PuzzleBlock]
@export var permanent := false

var _opened_locks: Dictionary[PuzzleBlock, bool] = {}
var _is_opened := false
var _gradient: Gradient
var _timer := 0.0
var _tween: Tween

func _ready() -> void:
	super._ready()
	_is_opened = false
	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)
	
	$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate(true)
	_gradient = $MeshInstance3D.get_active_material(0).albedo_texture.gradient


func _physics_process(delta: float) -> void:
	if not _is_opened or _timer >= open_delay: return

	_timer += delta
	var percentFull: float = max(1.0 - _timer / open_delay, 0.01)
	_gradient.set_offset(1, percentFull)

	if _timer >= open_delay:
		on.emit(self)
		is_on = true


func _on_lock_opened(block: PuzzleBlock) -> void:
	if _is_opened: return
	if not _opened_locks.get(block):
		_opened_locks[block] = true
		MyLogger.append_puzzle_log("Delay(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])

	for lock: bool in _opened_locks.values():
		if not lock: return

	if _tween and _tween.is_valid():
		_tween.kill()

	_is_opened = true
	_timer = 0
	_gradient.set_offset(1, 1.0)
	# 	MyLogger.append_puzzle_log("Delay(%s) was opened." % [puzzle_name])
	# 	on.emit(self)
	# else:
	# 	MyLogger.append_puzzle_log("Delay(%s) could not open." % [puzzle_name])
	# 	off.emit(self)
	#

func _on_lock_closed(block: PuzzleBlock) -> void:
	if permanent and is_on: return
	if _opened_locks.has(block):
		_opened_locks[block] = false
		MyLogger.append_puzzle_log("Delay(%s)'s Lock(%s) was closed." % [puzzle_name, block.puzzle_name])
	off.emit(self)
	is_on = false
	_is_opened = false
	_tween = create_tween()
	var percentFull: float = max(1.0 - _timer / open_delay, 0.01)
	_tween.tween_method(func(p: float) -> void:
		_gradient.set_offset(1, p),
		percentFull, 1.0, 0.5)
		

func _get_mesh() -> MeshInstance3D:
	return null
