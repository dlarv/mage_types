@tool
extends PuzzleBlock

@export var wait_time: float


func _ready() -> void:
	$Timer.wait_time = wait_time
	$Timer.start()


func _on_timer_timeout() -> void:
	on.emit(self)

