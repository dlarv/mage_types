extends Node

signal debug_mode_toggled(debugOn)
signal simplified_effects_toggled(toggled)

@export 
var debug_mode: bool: 
	set(value):
		debug_mode = value
		debug_mode_toggled.emit(value)

@export 
var use_simplified_effects: bool = true:
	set(value):
		use_simplified_effects = value
		simplified_effects_toggled.emit(value)

@export var enable_transmutation_hints: bool = true
