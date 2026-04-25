extends OverworldSpell


# Override 
func perform_action() -> void: 
	var e := _channel_element()
	if e.is_blank() and (not Settings.debug_mode or Settings.play_test_mode):
		return
	UIManager.toggle_golem_menu(e)
