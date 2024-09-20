extends Control
class_name ThreeStateButton 

signal StateChanged(state)

const UNSELECTED_STATE: int = 0
const FIRST_SELECTED_STATE: int = 1
const SECOND_SELECTED_STATE: int = 2

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
var IsLocked : bool: 
	get: return _isLocked 
	set(value):
		_isLocked = value
		state = UNSELECTED_STATE
		modulate =  lockedModulateColor  if value  else  unselectedModulateColor


var _isLocked: bool = false
var state : int = UNSELECTED_STATE

func OnPressed(toggled: bool) -> void:
	if not toggled:
		state = UNSELECTED_STATE
		modulate =  lockedModulateColor  if IsLocked  else  unselectedModulateColor
		return

	if !IsLocked && state == FIRST_SELECTED_STATE:
		state = SECOND_SELECTED_STATE
		modulate = selected2ModulateColor
	else:
		state = FIRST_SELECTED_STATE
		modulate = selected1ModulateColor

	StateChanged.emit(state)


func Reset() -> void:
	modulate = unselectedModulateColor
	state = UNSELECTED_STATE
	button.set_pressed_no_signal(false)
