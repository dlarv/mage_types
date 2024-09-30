extends Control
class_name ThreeStateButton 

signal state_changed(state)

const UNSELECTED_STATE: int = 0
const FIRST_SELECTED_STATE: int = 1
const SECOND_SELECTED_STATE: int = 2
const SECOND_STATE_UNSELECTED: int = 3

@export
var unselectedModulateColor: Color 
@export
var selected1ModulateColor: Color 
@export
var selected2ModulateColor: Color 
@export
var lockedModulateColor: Color 

@export
var button : Button 
var text : String:
	get: return button.text
	set(value):  button.text = value

var button_group: ButtonGroup:
	get: return button.button_group
	set(value): button.button_group = value

# Prevents button from entering 3rd state.
var is_locked: bool = false: 
	get: return is_locked 
	set(value):
		is_locked = value
		state = UNSELECTED_STATE
		modulate = lockedModulateColor if value else unselectedModulateColor


var state : int = UNSELECTED_STATE

func _on_pressed(toggled: bool) -> void:
	if not toggled:
		state = UNSELECTED_STATE
		modulate =  lockedModulateColor  if is_locked  else  unselectedModulateColor
	elif !is_locked && state == FIRST_SELECTED_STATE:
		state = SECOND_SELECTED_STATE
		modulate = selected2ModulateColor
	elif state == SECOND_SELECTED_STATE:
		state = FIRST_SELECTED_STATE
		modulate = selected1ModulateColor
		state_changed.emit(SECOND_STATE_UNSELECTED)
		return
	else:
		state = FIRST_SELECTED_STATE
		modulate = selected1ModulateColor

	state_changed.emit(state)


func reset() -> void:
	modulate = unselectedModulateColor
	state = UNSELECTED_STATE
	button.set_pressed_no_signal(false)
