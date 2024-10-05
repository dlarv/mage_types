extends Control 
class_name SettingsMenu 

@export var _debug_mode_toggle: CheckBox
@export var _transmutation_hint_toggle: CheckBox

func _ready():
	_debug_mode_toggle.set_pressed_no_signal(Settings.debug_mode)
	_transmutation_hint_toggle.set_pressed_no_signal(Settings.enable_transmutation_hints)

func on_debug_mode_toggled(val: bool) -> void:
	print("Debug mode toggled")
	Settings.debug_mode = val


func _on_transmutation_hints_toggled(value :bool) -> void:
	print("Transmutation hints toggled")
	Settings.enable_transmutation_hints = value

