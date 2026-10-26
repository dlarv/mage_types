extends AudioStreamPlayer

@export var footstep_cycle_duration := 0.4:
	set(val):
		footstep_cycle_duration = val
		if _cycle_timer:
			_cycle_timer.wait_time = footstep_cycle_duration
@export_enum("GRASS", "GRAVEL", "TILE", "WOOD", "WATER") var underfoot_material := "GRASS":
	set(val):
		underfoot_material = val
		match val:
			"GRASS":
				_curr_footsteps = grass_footsteps
			"TILE":
				_curr_footsteps = tile_footsteps
			"GRAVEL":
				_curr_footsteps = gravel_footsteps
			"WOOD":
				_curr_footsteps = wood_footsteps
			"WATER":
				_curr_footsteps = water_footsteps


@onready var grass_footsteps := [
	preload("res://assets/audio/footsteps/grass/0.ogg"),
	preload("res://assets/audio/footsteps/grass/1.ogg"),
	preload("res://assets/audio/footsteps/grass/2.ogg"),
	preload("res://assets/audio/footsteps/grass/3.ogg"),
	preload("res://assets/audio/footsteps/grass/4.ogg"),
	preload("res://assets/audio/footsteps/grass/5.ogg"),
	preload("res://assets/audio/footsteps/grass/6.ogg"),
	preload("res://assets/audio/footsteps/grass/7.ogg"),
]
@onready var gravel_footsteps := [
	preload("res://assets/audio/footsteps/gravel/0.ogg"),
	preload("res://assets/audio/footsteps/gravel/1.ogg"),
	preload("res://assets/audio/footsteps/gravel/2.ogg"),
	preload("res://assets/audio/footsteps/gravel/3.ogg"),
	preload("res://assets/audio/footsteps/gravel/4.ogg"),
	preload("res://assets/audio/footsteps/gravel/5.ogg"),
	preload("res://assets/audio/footsteps/gravel/6.ogg"),
	preload("res://assets/audio/footsteps/gravel/7.ogg"),
]
@onready var tile_footsteps := [
	preload("res://assets/audio/footsteps/tile/0.ogg"),
	preload("res://assets/audio/footsteps/tile/1.ogg"),
	preload("res://assets/audio/footsteps/tile/2.ogg"),
	preload("res://assets/audio/footsteps/tile/3.ogg"),
	preload("res://assets/audio/footsteps/tile/4.ogg"),
	preload("res://assets/audio/footsteps/tile/5.ogg"),
	preload("res://assets/audio/footsteps/tile/6.ogg"),
	preload("res://assets/audio/footsteps/tile/7.ogg"),
]
@onready var wood_footsteps := [
	preload("res://assets/audio/footsteps/wood/0.ogg"),
	preload("res://assets/audio/footsteps/wood/1.ogg"),
	preload("res://assets/audio/footsteps/wood/2.ogg"),
	preload("res://assets/audio/footsteps/wood/3.ogg"),
	preload("res://assets/audio/footsteps/wood/4.ogg"),
	preload("res://assets/audio/footsteps/wood/5.ogg"),
	preload("res://assets/audio/footsteps/wood/6.ogg"),
	preload("res://assets/audio/footsteps/wood/7.ogg"),
]
@onready var water_footsteps := [
	preload("res://assets/audio/footsteps/water/0.ogg"),
	preload("res://assets/audio/footsteps/water/1.ogg"),
	preload("res://assets/audio/footsteps/water/2.ogg"),
	preload("res://assets/audio/footsteps/water/3.ogg"),
	preload("res://assets/audio/footsteps/water/4.ogg"),
]
@onready var _curr_footsteps := grass_footsteps

var _player: Node3D
var _is_walking: bool:
	get:
		return (abs(_player.velocity.x) > 0 or abs(_player.velocity.z) > 0) \
				and _player.is_on_floor() \
				and _player.draggable == null
var _cycle_timer: Timer


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_cycle_timer = Timer.new()
	_cycle_timer.wait_time = footstep_cycle_duration
	_cycle_timer.one_shot = true
	_cycle_timer.autostart = false
	add_child(_cycle_timer)


func _process(delta: float) -> void:
	if not _is_walking: return
	elif playing: return
	elif not _cycle_timer.is_stopped(): return

	stream = _curr_footsteps.pick_random()
	play()
	_cycle_timer.start()
