extends Node

signal debug_mode_toggled(debugOn)
signal use_graph_stencils_toggled(useStencil)

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
