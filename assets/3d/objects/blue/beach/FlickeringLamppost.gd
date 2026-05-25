extends Node3D


@export var time_range := Vector2(0.5, 3.0)
@export var dim_light_range: Vector2 = Vector2()
@export var bright_light_range: Vector2 = Vector2()

var _curr_on_time: float
var _timer := 0.0
var _is_on := true


func _ready() -> void:
	toggle()


func _process(delta: float) -> void:
	if time_range == Vector2.ZERO: return

	_timer += delta
	if _timer < _curr_on_time: return

	_timer = 0
	_is_on = not _is_on

	toggle()


func toggle() -> void:
	_curr_on_time = randf_range(time_range.x, time_range.y)

	if _is_on:
		$SpotLight3D.light_energy = randf_range(bright_light_range.x, bright_light_range.y)
	else:
		$SpotLight3D.light_energy = randf_range(dim_light_range.x, dim_light_range.y)
