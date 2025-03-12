@tool
extends BattleAction 
class_name BattleItem 

signal item_consumed()

@export var effects: Array[EffectSlot] = []
var quantity: int 

var is_consumable: bool = true
var requirements: Array[ItemRequirement] = [] 


static func create(name: String, details: String="") -> BattleItem:
	var item = BattleItem.new()
	item.name = name
	item.details = details
	return item

func apply_effects(user: BattleActor, targets: Array) -> String:
	var msg := super.apply_effects(user, targets)
	apply_cost(user)

	for i in range(len(targets)):
		var target: BattleActor = targets[i]

		for effect in effects:
			var rand = randf()

			if rand <= effect.chance:
				msg += "\n%s" % effect.attack_effect.apply_effect(user, target, self)
				# Add status effect icon.
				if effect.attack_effect is Damage:
					# Check if character was defeated.
					if target.is_defeated:
						msg += "........%s was defeated." % target.ActorName
						continue
			else:
				Logger.append_log(Logger.LogType.BATTLE, "Item(%s) failed. Chance(%f) >= Rand(%f)" % [name, effect.chance, rand])
	return msg

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
			statusPotential += effect.chance
	return { 
		"status": statusPotential,
		"dmg": dmg,
	}
