@tool
extends Damage
class_name OverrideDamage
## Overrides damage calculator to use given stat instead of target's defenses or user's offenses.

@export_enum("user", "target", "both")
var actor_to_override := "target"
@export var override_stat: StatManager.Stats


func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var user := data.user
	var attack: float
	var defense: float
	match actor_to_override:
		"user":
			attack = user.get_stat(override_stat)
			defense = target.get_defense_stat(data.action)
		"target":
			attack = user.get_attack_stat(data.action)
			defense = target.get_stat(override_stat)
		_:
			attack = user.get_stat(override_stat)
			defense = target.get_stat(override_stat)

	var dmg := calculate_damage(attack, defense, effectiveness, data)
	_apply_to(data, target, dmg) 
	return data


func get_dmg_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> int:
	var user := data.user
	var action := data.action
	if target.statuses.blocking: return 0
	var attack: float
	var defense: float
	match actor_to_override:
		"user":
			attack = user.get_stat(override_stat)
			defense = target.get_defense_stat(action)
		"target":
			attack = user.get_attack_stat(action)
			defense = target.get_stat(override_stat)
		_:
			attack = user.get_stat(override_stat)
			defense = target.get_stat(override_stat)
	return calculate_damage(attack, defense, 1.0, data)


func _set_name(_val: String) -> void:
	name = "Damage (%s)" % StatManager.Stats.keys()[override_stat]
	resource_name = name
