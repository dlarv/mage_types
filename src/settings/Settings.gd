extends Node

signal debug_mode_toggled(debugOn)
signal use_graph_stencils_toggled(useStencil)
signal random_seed_changed(seedValue)

@export 
var debug_mode: bool: 
	set(value):
		debug_mode = value
		debug_mode_toggled.emit(value)

@export var enable_transmutation_hints := true
@export var use_mouse_targeting := true
@export var show_battle_turn_order := true
@export var show_opponent_intentions := true
@export var use_graph_stencils := true:
	set(val):
		use_graph_stencils = val
		use_graph_stencils_toggled.emit(val)

var random_seed := -1:
	set(val):
		random_seed = val
		if val > -1:
			random_seed_changed.emit(val)
			Logger.append_log(Logger.LogType.PUZZLE, "Set Seed(%d)" % val)

func set_player_name(name: String) -> void:
	var player = get_tree().get_nodes_in_group("player")
	if len(player) > 0:
		player = player[0]
	else:
		return


	random_seed = name.hash()

