extends Lockable

func _ready() -> void:
	if not _is_locked and permanent:
		self.collision_layer = 0
		$AnimationPlayer.play("opening")
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Gate(%s) is now permanently opened." % [puzzle_name])
		return
	super._ready()


func _physics_process(delta: float) -> void:
	# For some reason, collision_layer would oscillate between 0 and 1.
	if not _is_locked:
		self.collision_layer = 0

func _on_lock_opened(block: PuzzleBlock) -> bool:
	if not super._on_lock_opened(block): return false
	
	_open()
	return true

func _on_lock_closed(block: PuzzleBlock) -> bool:
	if not super._on_lock_closed(block): return false
	_close()
	return true


func _open(force:=false):
	self.collision_layer = 0
	$AnimationPlayer.play("opening")
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Gate(%s)was opened." % [puzzle_name])

func _close():
	self.collision_layer = 1
	$AnimationPlayer.play_backwards("opening")
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Gate(%s)was closed." % [puzzle_name])
