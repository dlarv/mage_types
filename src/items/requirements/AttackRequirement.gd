@tool
extends ItemRequirement
class_name AttackRequirement

@export var attacks: Array[Attack]
## If true, character trying to use this item cannot know any of these attacks.
## If false, they must know all of these attacks.
@export var incompatible: bool

# override
func check(actor: Variant) -> bool:
	actor = _get_battle_actor(actor)
	if incompatible: return _has_any(actor.attacks)
	return _has_all(actor.attacks)

func _has_any(actorAttacks: Array[_BattleAction]) -> bool:
	for attack: _BattleAction in attacks:
		if attack in actorAttacks:
			return false
	return true

func _has_all(actorAttacks: Array[_BattleAction]) -> bool:
	for attack: _BattleAction in attacks:
		if not attack in actorAttacks:
			return false
	return true 


func get_requirement_message() -> String:
	var msg := []
	if incompatible:
		msg.append("This actor cannot know any of the following spells:")
	else:
		msg.append("This actor must know all of the following spells:")

	for attack in attacks:
		# • = U+2022
		msg.append("• %s" % attack.name)

	return "\n".join(msg)
