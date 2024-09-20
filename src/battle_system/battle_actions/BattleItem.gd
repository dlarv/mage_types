@tool
extends BattleAction 
class_name BattleItem 

signal ItemConsumed()

var IsConsumable : bool = true
var Quantity : int 
var Requirement : ItemRequirement = null

@export
# Effect[]
var Effects = []

static func Create(name: String, details: String="") -> BattleItem:
	var item = BattleItem.new()
	item.Name = name
	item.Details = details
	return item

func ApplyEffects(user: BattleActor, targets) -> String:
	var msg = super.ApplyEffects(user, targets)

	for i in range(len(targets)):
		var target = targets[i]

		for effect in Effects:
			var rand = randf_range(0.0, 1.0)

			if rand <= effect.Chance:
				msg += "\n{effect.AttackEffect.ApplyEffect(user, target, this)}" % effect.AttackEffect.ApplyEffect(user, target, self)
				# Add status effect icon.
				if effect.AttackEffect is Damage:
					# Check if character was defeated.
					if target.Defeated:
						msg += "........{target.ActorName} was defeated." % target.ActorName
						continue
	return msg

# Override
func IsActionAvailable(actor: BattleActor) -> bool:
	if(IsConsumable and Quantity == 0): return false
	if(Requirement == null): return true

	return Requirement.Check(actor)
# override
func ApplyCost(user: BattleActor) -> void:
	if IsConsumable:
		Quantity -= 1
		ItemConsumed.emit()
