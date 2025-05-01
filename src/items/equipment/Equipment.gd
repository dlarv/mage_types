@tool
extends Item
class_name Equipment

@export var effects: Array[EquipmentEffect]:
	set(value):
		effects = value
		for effect in effects:
			if not effect: continue
			if not effect.activated.is_connected(_on_activated):
				effect.activated.connect(_on_activated)

var _actors := []
var _msgs := []


# virtual
func equip(actor: BattleActor) -> void: 
	if actor in _actors:
		unequip(actor)

	for effect in effects:
		effect.equip(actor)


# virtual
func unequip(actor: BattleActor) -> void: 
	if not actor in _actors: return

	_actors.remove_at(_actors.find(actor))

	for effect in effects:
		effect.unequip(actor)


func _on_activated(actor: BattleActor, msg: String) -> void:
	if len(msg) > 0:
		_msgs.append(msg)


func get_and_flush_msgs() -> Array:
	var output := _msgs
	_msgs = []
	return output
