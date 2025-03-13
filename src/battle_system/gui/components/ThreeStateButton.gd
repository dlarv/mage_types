extends Control
class_name ThreeStateButton 

signal state_changed(state: bool)

@export var unselected_modulate_color: Color 
@export var selected_modulate_color: Color 
@export var locked_modulate_color: Color 

@export var button: Button 
var _element: ElementalType
var text: String:
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
		state = false
		modulate = locked_modulate_color if value else unselected_modulate_color

var state: bool = false

func setup(element: ElementalType) -> void:
	_element = element

	var style_box := get_theme_stylebox(element.name.to_lower(), "Control")
	button.add_theme_stylebox_override("normal", style_box)

func _on_pressed(toggled: bool) -> void:
	if not toggled:
		state = false
		modulate = locked_modulate_color if is_locked else unselected_modulate_color
	elif !is_locked:
		state = true
		modulate = selected_modulate_color
	else:
		state = false
		modulate = unselected_modulate_color

	state_changed.emit(state)

func reset() -> void:
	modulate = unselected_modulate_color
	state = false
	button.set_pressed_no_signal(false)
