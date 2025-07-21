@tool
extends PuzzleBlock

@export var wait_time: float


func _ready() -> void:
	if Engine.is_editor_hint(): return
	$Timer.wait_time = wait_time
	$Timer.start()


func _on_timer_timeout() -> void:
	on.emit(self)

