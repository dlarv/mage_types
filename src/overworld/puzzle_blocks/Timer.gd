@tool
extends PuzzleBlock

@export var lock: PuzzleBlock
@export var delay: float
@export var allow_early_close := false

func _ready() -> void:
	$AnimationPlayer.speed_scale = 60 / delay
	if not lock: return
	lock.on.connect(_on_lock_opened)
	lock.off.connect(_on_lock_closed)


func _on_lock_opened(block: PuzzleBlock) -> void:
	Logger.append_puzzle_log("Timer(%s) was started." % [puzzle_name])
	$AnimationPlayer.play("turning")
	on.emit(self)
	$Timer.start(delay)
	await $Timer.timeout
	off.emit(self)


func _on_lock_closed(block: PuzzleBlock) -> void:
	if allow_early_close:
		off.emit(self)
		

func _get_mesh() -> MeshInstance3D:
	return null
