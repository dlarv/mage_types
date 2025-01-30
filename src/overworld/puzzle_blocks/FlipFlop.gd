extends PuzzleBlock

@export var on_length := 2.0
@export var off_length := 2.0
@export var start_state := true
@export var offset := 0.0

func _ready() -> void:
	$On.wait_time = on_length
	$Off.wait_time = off_length
	await get_tree().create_timer(offset).timeout
	if start_state:
		_on_on_timeout()
	else:
		_on_off_timeout()


func _on_on_timeout() -> void:
	on.emit(self)
	if is_on:
		$Off.start()

func _on_off_timeout() -> void:
	off.emit(self)
	if is_on:
		$On.start()
