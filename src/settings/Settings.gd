extends Node

signal debug_mode_toggled(debugOn)
signal random_seed_changed(seedValue)
signal player_name_changed(name)

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

var random_seed := -1:
	set(val):
		random_seed = val
		if val > -1:
			seed(val)
			random_seed_changed.emit(val)
			Logger.append_world_log("Set Seed(%d)" % val)

var loaded_save_data: FileAccess = null
var player_name: String = "Player":
	set(val):
		player_name = val
		player_name_changed.emit(val)


func _ready() -> void:
	random_seed = "Player".hash()


func set_player_name(name: String) -> void:
	# var player = get_tree().get_nodes_in_group("player")
	# if len(player) > 0:
	# 	player = player[0]

	player_name = name
	random_seed = name.hash()
