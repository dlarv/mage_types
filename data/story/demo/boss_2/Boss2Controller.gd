extends ScriptedOpponent 

const BUFF_INDEX = 0
const STRIKE_INDEX = 1
const GENERATE_INDEX = 2

var _turn_counter := 0
var _actor: BattleActor
var _strike_attack: Attack
var _buff_attack: Attack
var _generate_attack: Attack
var _purple: ElementalType

func setup(team: Array) -> void:
	super.setup(team)
	_actor = team[0]
	_strike_attack = _actor.attacks[STRIKE_INDEX]
	_buff_attack = _actor.attacks[BUFF_INDEX]
	_generate_attack = _actor.attacks[GENERATE_INDEX]
	_purple = ElementManager.Purple

func get_actions(otherTeam: Array) -> Array:
	var actions := []
	var targets := []
	var attack: Attack
	_turn_counter += 1

	if _turn_counter == 1:
		_actor.bias_reversion_threshold = 1.1
		_strike_attack.priority = 1
	elif _turn_counter == 4:
		_actor.bias_reversion_threshold = 0.6
		_strike_attack.priority = 0

	#  Always use strike on the first two turns.
	if _turn_counter < 3:
		attack = _strike_attack
		targets.append(otherTeam.pick_random())
	# If boss is purple.
	elif _actor.is_element(_purple):
		# Generate affinity.
		if _actor.element1 == _purple \
				and _actor.get_affinity_for(_purple) < _strike_attack.cost:
			attack = _generate_attack
			targets.append(_actor)
		# Use strike.
		else:
			attack = _strike_attack
			targets.append(otherTeam.pick_random())
	# If boss is not purple...
	else:
		attack = _buff_attack
		targets.append(_actor)

	actions.append(ActorAction.new(_actor, attack, targets, TEAM_INDEX))
	return actions
