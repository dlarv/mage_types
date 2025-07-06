extends OverworldSpell

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_golem_menu") and Inventory.has_key_item(KeyItem.UniqueId.GOLEM):
		perform_action()
		get_viewport().set_input_as_handled()

# Override 
func perform_action() -> void: 
	var e := _channel_element()
	if e.is_blank() and not Settings.debug_mode:
		return
	UIManager.toggle_golem_menu(e)
