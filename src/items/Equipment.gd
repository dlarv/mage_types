extends Item
class_name Equipment

var _connected_to: BattleActor = null
var _msgs := []

# virtual
func equip(actor: BattleActor) -> void: 
	if _connected_to != null:
		if _connected_to == actor: 
			return
		else:
			unequip(_connected_to)
	_connected_to = actor

# virtual
func unequip(actor: BattleActor) -> void: 
	_connected_to = null

func _on_activated(msg: String) -> void:
	_msgs.append(msg)

func get_and_flush_msgs() -> Array:
	var output := _msgs
	_msgs = []
	return output
