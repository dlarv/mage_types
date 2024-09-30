extends Node

signal debug_mode_toggled(debugOn)

@export 
var debug_mode: bool: 
	set(value):
		debug_mode = value
		debug_mode_toggled.emit(value)

@export
var enable_transmutation_hints: bool = true
