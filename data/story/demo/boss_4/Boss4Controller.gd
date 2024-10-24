extends ScriptedOpponent

var _actor: BattleActor
var _drain_attack: Attack
var _recoil_attack: Attack

func setup(team: Array) -> void:
	super.setup(team)
	_actor = team[0]
	_drain_attack = _actor.attacks[0]
	_recoil_attack = _actor.attacks[1]


func get_actions(otherTeam: Array) -> Array:
	var actions := []
	var attack: Attack

	if _actor.current_hp < float(_actor.hp) / 2:
		attack = _drain_attack
	else:
		attack = _recoil_attack

	actions.append(ActorAction.new(_actor, attack, [ otherTeam.pick_random() ], TEAM_INDEX))
	return actions
