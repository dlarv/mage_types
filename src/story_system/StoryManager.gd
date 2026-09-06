@tool
extends BaseStoryManager

enum DialogSignal { DIALOG_ENDED, PLAY_CUTSCENE, BATTLE_STARTED, ADD_ALLY, REMOVE_ALLY, MENU_OPENED } 


func get_valid_signals() -> Array:
	return DialogSignal.keys()


func get_signal_from_key(key: String) -> Variant: 
	return DialogSignal[key.to_upper()]


