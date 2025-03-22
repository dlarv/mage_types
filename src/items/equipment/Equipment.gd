@tool
extends Item
class_name Equipment

@export var effects: Array[EquipmentEffect]:
	set(value):
		effects = value
		# effects = value.filter(func(val): return val != null)
		# if Engine.is_editor_hint(): return
		for effect in effects:
			if not effect: continue
			if not effect.activated.is_connected(_on_activated):
				effect.activated.connect(_on_activated)

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

	for effect in effects:
		effect.equip(actor)

# virtual
func unequip(actor: BattleActor) -> void: 
	_connected_to = null
	for effect in effects:
		effect.unequip(actor)

func _on_activated(msg: String) -> void:
	if len(msg) > 0:
		_msgs.append(msg)

func get_and_flush_msgs() -> Array:
	var output := _msgs
	_msgs = []
	return output
