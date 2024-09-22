extends Control 
class_name SettingsMenu 

func on_debug_mode_toggled(val: bool) -> void:
	print("Debug mode toggled");
	Settings.debug_mode = val
