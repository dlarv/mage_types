extends PuzzleBlock

@export var lock: PuzzleBlock

func _ready() -> void:
	if lock == null: return
	lock.on.connect(_on_lock_opened)
	lock.invalid_off.connect(_on_lock_closed)

func _on_lock_opened(block: PuzzleBlock) -> void:
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Relay(%s) was opened." % [puzzle_name])
	on.emit(self)

func _on_lock_closed(block: PuzzleBlock) -> void:
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Relay(%s) was closed." % [puzzle_name])
	off.emit(self)
