@tool
extends PuzzleBlock

@export var lock: PuzzleBlock

var _depressed := false

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	if lock == null: return
	lock.on.connect(_on_lock_opened)
	lock.invalid_off.connect(_on_lock_closed)

func _on_lock_opened(block: PuzzleBlock) -> void:
	MyLogger.append_puzzle_log("Relay(%s) was opened." % [puzzle_name])
	if not _depressed:
		$relay_pin/AnimationPlayer.play("depress")
	_depressed = true
	await $relay_pin/AnimationPlayer.animation_finished

	on.emit(self)

func _on_lock_closed(block: PuzzleBlock) -> void:
	MyLogger.append_puzzle_log("Relay(%s) was closed." % [puzzle_name])
	if _depressed:
		$relay_pin/AnimationPlayer.play_backwards("depress")
	_depressed = false
	off.emit(self)
