extends BattleActionAnimation

@export var MAX := 1
@export var delta: Vector2
@export var time_delay: float
var _counter: int

func _ready():
	animation.emitting = true
	_counter = 0

func _process(delta: float) -> void: return

func _on_gpu_particles_2d_finished() -> void:
	if _counter == MAX - 1: 
		animation_finished.emit()
		queue_free()
		return
	_counter += 1
	position += delta
	await get_tree().create_timer(time_delay).timeout
	animation.restart()
