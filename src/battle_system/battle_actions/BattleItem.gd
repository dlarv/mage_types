@tool
extends BattleAction 
class_name BattleItem 

signal item_consumed()

var is_consumable: bool = true
var quantity: int 
var requirements: Array[ItemRequirement] = [] 

@export
var effects: Array[Effect] = []

static func create(name: String, details: String="") -> BattleItem:
	var item = BattleItem.new()
	item.name = name
	item.details = details
	return item

func apply_effects(user: BattleActor, targets) -> String:
	var msg = super.apply_effects(user, targets)

	for i in range(len(targets)):
		var target = targets[i]

		for effect in effects:
			var rand = randf_range(0.0, 1.0)

			if rand <= effect.chance:
				msg += "\n%s" % effect.AttackEffect.apply_effect(user, target, self)
				# Add status effect icon.
				if effect.attack_effect is Damage:
					# Check if character was defeated.
					if target.is_defeated:
						msg += "........%s was defeated." % target.ActorName
						continue
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
func apply_cost(user: BattleActor) -> void:
	if is_consumable:
		quantity -= 1
		item_consumed.emit()
