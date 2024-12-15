extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_element_menu"):
		visible = not visible

