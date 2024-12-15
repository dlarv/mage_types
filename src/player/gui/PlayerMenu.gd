extends Control 

signal pause_world(val: bool)

@export var inventory_screen: InventoryScreen 
@export var characters_menu: CharactersMenu
@export var world: Node3D 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_player_menu"):
		get_window().set_input_as_handled()
		visible = !visible
		# world.process_mode = Node.PROCESS_MODE_INHERIT if !visible  else Node.PROCESS_MODE_DISABLED
		pause_world.emit(not visible)

	if event is InputEventKey and visible and event.keycode == KEY_ESCAPE:
	# if visible and event.is_action_pressed("toggle_pause_menu"):
		get_window().set_input_as_handled()
		visible = false 
		# world.process_mode = Node.PROCESS_MODE_INHERIT
		pause_world.emit(false)

