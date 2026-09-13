extends OverworldSpell


# Override 
func perform_action() -> void: 
	var e := _channel_element()
	if e.is_blank() and (not ProjectSettings.get_setting("custom/general/debug_mode") \
			or ProjectSettings.get_setting("play_test_mode")):
		return
	UIManager.toggle_golem_menu(e)
