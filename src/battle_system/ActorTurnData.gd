extends Object
class_name ActorTurnData

## Datatype for actions selected by BattleActors.
## These are basically like an instance of a _BattleAction.
# public static ActorAction[] Flee = new ActorAction[0]

const Effects := BattleActor.StatusEffectManager.StatusEffects
const EXPRESSION_VARS: PackedStringArray = ["total_dmg", "prev_dmg", "recoil_dmg", "missed", "phobia_dmg"]

var user: BattleActor 
var priority: int 
var action: _BattleAction 
var targets: Array[BattleActor] = []
var team_index: int
var effectiveness: float
var failed_effects: Array[EffectSlot] = []
var total_dmg: int
var prev_dmg: int
var recoil_dmg: int
var phobia_dmg: int
var missed: bool
var element: ElementalType
var user_was_defeated := false

var new_status_effects: Array[Effects] = []
var activated_status_effects: Array[Effects] = []
var expired_status_effects: Array[Effects] = []

var effects: Dictionary[BattleActor, ActorTurnEffect] = {}


func _init(actor: BattleActor, action: _BattleAction, targets: Array[BattleActor], teamIndex: int) -> void:
	self.user = actor
	self.action = action
	if action:
		self.priority = action.priority
	self.targets = targets
	self.team_index = teamIndex
	missed = false
	total_dmg = 0
	prev_dmg = 0
	recoil_dmg = 0
	phobia_dmg = 0
	element = ElementManager.Blank


func execute() -> ActorTurnData:
	action.apply_effects(self)
	user.action_used.emit(action)
	return self


func resolve_end_of_turn(allies: Array[BattleActor], enemies: Array[BattleActor]) -> void:
	user.resolve_end_of_turn(allies, enemies, self)


func add_actor(actor: BattleActor) -> void:
	if actor == user: return
	effects[actor] = ActorTurnEffect.new()


func add_inflicted_effect(actor: BattleActor, effect: Effects) -> void:
	if actor == user:
		new_status_effects.append(effect)
	else:
		effects[actor].new_status_effects.append(effect)


func add_activated_effect(actor: BattleActor, effect: Effects, data: Variant=null) -> void:
	if actor == user:
		activated_status_effects.append(effect)
	else:
		effects[actor].activated_status_effects.append(effect)


func set_defeated(actor: BattleActor) -> void:
	if actor == user:
		user_was_defeated = true
	else:
		effects[actor].was_defeated = true


func get_vars() -> Array[Variant]:
	var output := []
	for key in EXPRESSION_VARS:
		output.append(get(key))
	return output

func get_defeated() -> Array[BattleActor]:
	var output: Array[BattleActor] = []
	if user_was_defeated:
		output.append(user)
	
	for actor in effects:
		if effects[actor].was_defeated:
			output.append(actor)
	return output


static func flee() -> ActorTurnData: return ActorTurnData.new(null, null, [], -1)
static func empty(user: BattleActor=null) -> ActorTurnData: return ActorTurnData.new(user, null, [], -1)
func is_flee() -> bool: return team_index == -1
func is_empty() -> bool: return team_index == -2


class ActorTurnEffect:
	var was_defeated := false
	var blocked_dmg := 0
	var new_status_effects: Array[Effects]
	var activated_status_effects: Array[Effects]
