@tool
extends EditorPlugin

const CUSTOM_SETTING_ROOT_PATH := "custom"

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_custom_setting("general", "debug_mode", false)
	add_custom_setting("general", "play_test_mode", false)
	add_custom_setting("battle", "enable_transmutation_hint", true)
	add_custom_setting("general", "use_mouse_targeting", true)
	add_custom_setting("battle", "show_battle_turn_order", true)
	add_custom_setting("battle", "show_opponent_intentions", true)
	add_custom_setting("battle", "auto_end_turn", true)
	add_custom_setting("general", "helper_text_interval", 0.8)
	add_custom_setting("general", "saved_game_directory", "user://games")



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func add_custom_setting(subcategory: String, name: String, value: Variant, restart:=false) -> void:
	var path := "%s/%s/%s" % [CUSTOM_SETTING_ROOT_PATH, subcategory, name]
	
	if not ProjectSettings.has_setting(path): 
		ProjectSettings.set_setting(path, value)

	ProjectSettings.set_restart_if_changed(path, restart)
