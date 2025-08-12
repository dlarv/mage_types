extends Control

signal state_changed(state: bool)

@export var unselected_modulate_color: Color 
@export var selected_modulate_color: Color 
@export var locked_modulate_color: Color 

var _element: ElementalType
var text: String:
	get: return %Button.text
	set(value):  %Button.text = value

var button_group: ButtonGroup:
	get: return %Button.button_group
	set(value): %Button.button_group = value

# Prevents %Button from entering 3rd state.
var is_locked: bool = false: 
	get: return is_locked 
	set(value):
		is_locked = value
		state = false
		modulate = locked_modulate_color if value else unselected_modulate_color
var state: bool = false

var shortcut_keycode := ""

func setup(element: ElementalType) -> void:
	_element = element

	%ShieldIcon.visible = element.is_defensive_type
	%SwordIcon.visible = not element.is_defensive_type

	var style_box := get_theme_stylebox(element.name.to_lower(), "Control")
	%Button.add_theme_stylebox_override("normal", style_box)


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or len(shortcut_keycode) == 0: return
	
	if event.is_action_pressed(shortcut_keycode):
		get_window().set_input_as_handled()
		%Button.button_pressed = true


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
	%Button.set_pressed_no_signal(false)
