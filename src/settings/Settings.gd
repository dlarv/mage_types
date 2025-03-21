extends Node

signal debug_mode_toggled(debugOn)

@export 
var debug_mode: bool: 
	set(value):
		debug_mode = value
		debug_mode_toggled.emit(value)

@export var enable_transmutation_hints := true
@export var use_mouse_targeting := true
@export var show_battle_turn_order := true
@export var show_opponent_intentions := true
