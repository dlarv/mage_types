@tool
extends Node3D

@export_category("Lighting")
@export var light: Light3D
@export var energy := 1.0:
	set(val):
		energy = val
		if light:
			light.light_energy = val
@export var color := Color.WHITE:
	set(val):
		color = val
		if light:
			light.light_color = val

@export_category("Flickering")
@export var is_flickering := false:
	set(val):
		is_flickering = val
		property_list_changed.emit()
@export var time_range := Vector2(0.5, 3.0)
@export var dim_light_range: Vector2 = Vector2()
@export var bright_light_range: Vector2 = Vector2()


var disabled := false

var _curr_on_time: float
var _timer := 0.0
var _is_on := true


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"time_range","dim_light_range","bright_light_range":
			property.usage = PROPERTY_USAGE_NO_EDITOR if not is_flickering else PROPERTY_USAGE_DEFAULT
		"energy":
			property.usage = PROPERTY_USAGE_DEFAULT if not is_flickering else PROPERTY_USAGE_NO_EDITOR


func _ready() -> void:
	if disabled: return
	if is_flickering:
		toggle()
	else:
		light.light_energy = energy
		light.light_color = color


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if disabled or time_range == Vector2.ZERO or not is_flickering: return

	_timer += delta
	if _timer < _curr_on_time: return

	_timer = 0
	_is_on = not _is_on

	toggle()


func toggle() -> void:
	_curr_on_time = randf_range(time_range.x, time_range.y)

	if _is_on:
		light.light_energy = randf_range(bright_light_range.x, bright_light_range.y)
	else:
		light.light_energy = randf_range(dim_light_range.x, dim_light_range.y)
