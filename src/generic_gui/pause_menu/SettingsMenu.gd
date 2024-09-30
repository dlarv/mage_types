extends Control 
class_name SettingsMenu 

func on_debug_mode_toggled(val: bool) -> void:
	print("Debug mode toggled")
	Settings.debug_mode = val


func _on_transmutation_hints_toggled(value :bool) -> void:
	print("Transmutation hints toggled")
	Settings.enable_transmutation_hints = value

