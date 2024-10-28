extends ScriptedOpponent

const PHOBIA_INDEX := 0
const HIT_INDEX := 1

var _actor: BattleActor
var _phobia_attack: Attack
var _hit_attack: Attack
var _turn_counter: int

func setup(otherTeam: Array) -> void:
	super.setup(otherTeam)
	_actor = team[0]
	_hit_attack = _actor.attacks[HIT_INDEX].duplicate()
	_phobia_attack = _actor.attacks[PHOBIA_INDEX]
	_turn_counter = 0

func get_actions(otherTeam: Array) -> Array:
	var actions := []
	var attack := _phobia_attack
	var targets: Array

	if _turn_counter < 4:
		attack = _phobia_attack
		targets = otherTeam
	else:
		attack = _hit_attack
		var target = otherTeam.pick_random()
		var element := _calculate_transmutations(target)
		attack.element = element
		attack.name = "%s Strike" % element.get_bb_code_name()
		targets = [target]

	_turn_counter += 1
	_turn_counter %= 6

	actions.append(ActorAction.new(_actor, attack, targets, TEAM_INDEX))
	return actions

func _calculate_transmutations(target: BattleActor) -> ElementalType:
	var MAX := 3
	var element1 := target.element1
	var element2 := target.element2
	var maxCount := 0
	var maxElement: ElementalType = null

	for element in ElementManager.elements:
		var counter := 0
		var e1 := element1
		var e2 := element2

		var m1 := ElementManager.get_matchup(element, element1)
		if m1 != null:
			counter += 1
			e1 = m1

		var m2 := ElementManager.get_matchup(element, element2)
		if m2 != null:
			counter += 1
			e2 = m2

		var m3 :=  ElementManager.get_matchup(e1, e2)
		if m3 != null:
			counter += 1

		if counter == MAX:
			return element
		elif counter > maxCount:
			maxCount = counter
			maxElement = element

	return maxElement
