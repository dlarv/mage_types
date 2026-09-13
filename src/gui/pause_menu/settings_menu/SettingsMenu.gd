extends Menu

@export var _debug_mode_toggle: CheckBox
@export var _transmutation_hint_toggle: CheckBox

func _ready() -> void:
	_debug_mode_toggle.set_pressed_no_signal(ProjectSettings.get_setting("custom/general/debug_mode"))
	#_transmutation_hint_toggle.set_pressed_no_signal(ProjectSettings.get_setting("custom/enable_transmutation_hint"))


func _on_transmutation_hints_toggled(value: bool) -> void:
	ProjectSettings.set_setting("custom/battle/enable_transmutation_hint", value)


func _on_debug_mode_toggled(value: bool) -> void:
	ProjectSettings.set_setting("custom/general/debug_mode", value)


func _on_show_intentions_toggled(value: bool) -> void:
	ProjectSettings.set_setting("custom/battle/show_opponent_intentions", value)


func _on_show_turn_order_toggled(value: bool) -> void:
	ProjectSettings.set_setting("custom/battle/show_battle_turn_order", value)


func _on_auto_end_turn_toggled(value: bool) -> void:
	ProjectSettings.set_setting("custom/battle/auto_end_turn", value)
