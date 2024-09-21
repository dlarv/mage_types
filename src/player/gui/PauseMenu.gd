extends Control 
class_name PauseMenu 

@export
var inventoryScreen: InventoryScreen 
@export
var world: Node3D 

func InitInventory(inventory: Inventory) -> void:
	inventoryScreen.Setup(inventory)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_pause_menu"):
		visible = !visible
		world.process_mode = Node.PROCESS_MODE_INHERIT if !visible  else Node.PROCESS_MODE_DISABLED
