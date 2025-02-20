extends Menu

@export var _debug_mode_toggle: CheckBox
@export var _transmutation_hint_toggle: CheckBox
@export var _simple_effects_toggle: CheckBox

func _ready():
	_debug_mode_toggle.set_pressed_no_signal(Settings.debug_mode)
	_transmutation_hint_toggle.set_pressed_no_signal(Settings.enable_transmutation_hints)
	_simple_effects_toggle.set_pressed_no_signal(Settings.use_simplified_effects)

func on_debug_mode_toggled(value: bool) -> void:
	print("Debug mode toggled")
	Settings.debug_mode = value


func _on_transmutation_hints_toggled(value: bool) -> void:
	print("Transmutation hints toggled")
	Settings.enable_transmutation_hints = value



func _on_simple_effects_toggled(value: bool) -> void:
	print("Simple side effects toggled")
	Settings.use_simplified_effects = value
