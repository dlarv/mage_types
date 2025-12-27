@tool
extends _Item
class_name Equipment

@export var effects: Array[_EquipmentEffect]:
	set(value):
		effects = value
		for effect in effects:
			if not effect: continue
			if not effect.activated.is_connected(_on_activated):
				effect.activated.connect(_on_activated)
@export var has_overworld_use := false
var _actors := []

func _init() -> void: pass

# virtual
func equip(actor: BattleActor) -> void: 
	if actor in _actors:
		unequip(actor)
		
	_actors.append(actor)
	for effect in effects:
		effect.equip(actor)


# virtual
func unequip(actor: BattleActor) -> void: 
	if not actor in _actors: return

	_actors.remove_at(_actors.find(actor))

	for effect in effects:
		effect.unequip(actor)


func _on_activated(actor: BattleActor, msg: String) -> void:
	actor.equipment_activated.emit(self)
