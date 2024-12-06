extends Control

@export var world: Node

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_matchup_menu"):
		get_window().set_input_as_handled()
		visible = !visible
		if world != null:
			world.process_mode = Node.PROCESS_MODE_INHERIT if !visible  else Node.PROCESS_MODE_DISABLED
	if event is InputEventKey and visible and event.keycode == KEY_ESCAPE:
		get_window().set_input_as_handled()
		visible = false 
		if world != null:
			world.process_mode = Node.PROCESS_MODE_INHERIT
