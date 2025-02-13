@tool
extends Item 
class_name Equipment 

@export var effects: Array[EquipmentEffect]:
	set(value):
		for effect in effects:
			if not effect.activated.is_connected(_on_activated):
				effect.activated.connect(_on_activated)
var _connected_to: BattleActor = null
var _msgs := []


func equip(battleActor: BattleActor) -> void:
	if _connected_to != null:
		if _connected_to == battleActor: return
		else:
			unequip(_connected_to)
	_connected_to = battleActor

	for effect in effects:
		effect.equip(battleActor)

func unequip(battleActor: BattleActor) -> void:
	_connected_to = null

	for effect in effects:
		effect.unequip(battleActor)

func _on_activated(msg: String) -> void:
	_msgs.append(msg)

func get_and_flush_msgs() -> Array:
	var output := _msgs
	_msgs = []
	return output
