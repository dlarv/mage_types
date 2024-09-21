extends Control 
class_name SettingsMenu 

func OnDebugModeToggled(val: bool) -> void:
	print("Debug mode toggled");
	# Settings.Singleton.DebugMode = val;
