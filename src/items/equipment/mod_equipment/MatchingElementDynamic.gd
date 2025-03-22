@tool
extends ModEquipmentEffect
class_name MatchingElementDynamic

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

## Amount to add to stats, if this is the only BattleActor with {element}.
@export var only_match_boost: float
## Amount to add to stats, if no opponents are {element}, but some allies are.
## Boost = number_of_allies * ally_match_boost
@export var ally_match_boost: float
## Amount to add to stats, if some opponents are {element}.
## Boost = number_of_opponents * opponent_match_boost
@export var opponent_match_boost: float

@export_enum("melee", "ranged", "both") 
var targeted_stat := "both"

var _actor: BattleActor
var _original_melee: float
var _original_ranged: float

#override
func equip(actor: BattleActor) -> void:
	_actor = actor
	actor.add_func_override(actor.resolve_end_of_turn, end_of_turn)
	if targeted_stat == "both" or targeted_stat == "melee":
		_original_melee = actor.stat_manager._base_melee_attack
	if targeted_stat == "both" or targeted_stat == "ranged":
		_original_ranged = actor.stat_manager._base_ranged_attack

#override
func unequip(actor: BattleActor) -> void:
	actor.remove_func_override(actor.resolve_end_of_turn)
	_actor = null

func end_of_turn(allies:Array, opponents: Array) -> void:
	Logger.append_log(Logger.LogType.BATTLE, "MED equipment altered %s.apply_damage(...)" 
			% _actor.name)
	_actor.resolve_end_of_turn(allies, opponents, false)
	if not _actor.is_element(element): return
	var totalAllies := 0
	var totalOpps := 0

	for ally in allies:
		totalAllies += 1 if ally.is_element(element) else 0

	for opp in opponents:
		totalOpps += 1 if opp.is_element(element) else 0

	var mod := 0.0
	var msg := "There are other %s on the field! Their strength was " % element.get_bb_code_name()
	if totalOpps > 0:
		mod = opponent_match_boost * totalOpps
	# _actor is counted from within the allies array.
	elif totalAllies == 1:
		mod = only_match_boost
		msg = "%s is the only %s on the field! Their strength was " \
				% [_actor.name, element.get_bb_code_name()]
	else:
		mod = ally_match_boost * totalAllies

	var verb: String
	if mod > 0:
		verb = "boosted!"
	else:
		verb = "weakened!"

	activated.emit(msg + verb)

	if targeted_stat == "both" or targeted_stat == "melee":
		_actor.stat_manager.mod_base_stat(StatManager.Stat.MELEE_ATTACK, mod, 1)
	if targeted_stat == "both" or targeted_stat == "ranged":
		_actor.stat_manager.mod_base_stat(StatManager.Stat.RANGED_ATTACK, mod, 1)
	
