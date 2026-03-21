@tool
extends _BattleAction 
class_name BattleItem 

signal item_consumed()

@export var effects: Array[EffectSlot] = []
var quantity: int 

var is_consumable: bool = true
var requirements: Array[ItemRequirement] = [] 


static func create(name: String, details: String="") -> BattleItem:
	var item := BattleItem.new()
	item.name = name
	item.details = details
	return item

func apply_effects(data: ActorTurnData) -> ActorTurnData:
	super.apply_effects(data)
	apply_cost(data.user)

	for i in range(len(data.targets)):
		var target: BattleActor = data.targets[i]

		for effect in effects:
			var rand := randf()

			if rand <= effect.chance:
				effect.apply_effect(data, data.target, 1.0)

				if effect.attack_effect is Damage:
					if target.is_defeated:
						data.set_defeated(target)
						continue
			else:
				data.failed_effects.append(effect)
				MyLogger.append_battle_log("_Item(%s) failed. Chance(%f) >= Rand(%f)" 
						% [name, effect.chance, rand])
	return data

# Override
func is_action_available(actor: BattleActor) -> bool:
	if(is_consumable and quantity == 0): return false
	if(requirements == null): return true
	if len(requirements) == 0: return true

	for req in requirements:
		if not req.check(actor):
			return false
	return true

# override
func apply_cost(user: BattleActor) -> float:
	if is_consumable:
		quantity -= 1
		item_consumed.emit()
	return 0

# override
func get_attack_potential(user: BattleActor, target: BattleActor) -> Dictionary:
	var statusPotential := 0.0
	var dmg := 0
	for effect in effects:
		dmg += effect.get_dmg_potential(user, self, target)
		if effect.attack_effect is StatusEffect:
			statusPotential += effect.get_setup_potential(user, target, self)
	return { 
		"status": statusPotential,
		"dmg": dmg,
	}
