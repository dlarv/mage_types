extends Node

signal debug_mode_toggled(debugOn: bool)
signal random_seed_changed(seedValue: float)
signal player_name_changed(name: String)

const SAVE_ROOT_DIR := "user://games"

@export var debug_mode: bool: 
	set(value):
		debug_mode = value
		debug_mode_toggled.emit(value)
@export var play_test_mode := false
@export var enable_transmutation_hints := true
@export var use_mouse_targeting := true
@export var show_battle_turn_order := true
@export var show_opponent_intentions := true
@export var auto_end_turn := true
@export var helper_text_interval := 0.8

var random_seed := -1:
	set(val):
		random_seed = val
		if val > -1:
			seed(val)
			random_seed_changed.emit(val)
			MyLogger.append_world_log("Set Seed(%d)" % val)

var loaded_save_data: FileAccess = null
var player_name: String = "Player":
	set(val):
		player_name = val
		player_name_changed.emit(val)


func _ready() -> void:
	random_seed = randi()


func set_player_name(name: String) -> void:
	player_name = name


func reload() -> void:
	# TODO
	pass
