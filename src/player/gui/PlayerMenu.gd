extends Control 

@export var inventory_screen: InventoryScreen 
@export var world: Node3D 

func init_movepool(id: int, movepool: Movepool) -> void:
	pass

func init_inventory(inventory: Inventory) -> void:
	inventory_screen.setup(inventory)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_player_menu"):
		get_window().set_input_as_handled()
		visible = !visible
		world.process_mode = Node.PROCESS_MODE_INHERIT if !visible  else Node.PROCESS_MODE_DISABLED
