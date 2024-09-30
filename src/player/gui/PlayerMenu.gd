extends Control 

@export
var inventoryScreen: InventoryScreen 
@export
var world: Node3D 

func init_movepool(id: int, movepool: Movepool):
	pass

func init_inventory(inventory: Inventory) -> void:
	inventoryScreen.setup(inventory)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_player_menu"):
		visible = !visible
		world.process_mode = Node.PROCESS_MODE_INHERIT if !visible  else Node.PROCESS_MODE_DISABLED
