extends PuzzleBlock

@export var on_length := 2.0
@export var off_length := 2.0

func _ready() -> void:
	$On.wait_time = on_length
	$Off.wait_time = off_length
	$On.start()


func _on_on_timeout() -> void:
	on.emit(self)
	if is_on:
		$Off.start()

func _on_off_timeout() -> void:
	off.emit(self)
	if is_on:
		$On.start()
