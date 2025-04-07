@tool
extends Resource 
class_name _BattleAction 

# public static _BattleAction Flee { get private set } = new()

enum TargetType { SELF, ALLY, ALLIES, ENEMY, ENEMIES, ALL, RANDOM }
enum AttackRange { MELEE, RANGED, STATUS }

@export var name: String = "Hit":
	set(value):
		name = value
		resource_name = value
@export var animation: PackedScene
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)

var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

		# if "_needs_elemental_effect_override" in self \
		# 		and self._needs_elemental_effect_override \
		# 		and self.has_method("elemental_effect_override"):
		# 	var indirect = self
		# 	indirect.elemental_effect_override(value)
@export var priority: int = 0
@export var attack_range: AttackRange = AttackRange.MELEE
@export var target: TargetType = TargetType.ENEMY
@export_multiline var details: String 

# virtual
func play_animation(start: Vector2, end: Vector2, parent: Node2D) -> Node:
	var obj = animation.instantiate()
	obj._play(start, end, parent, element)
	return obj

# virtual
func is_action_available(actor: BattleActor) -> bool:
	return true

# virtual
## Used by opponent controllers to determine the probability of inflicting a status condition and amount of dmg.
func get_attack_potential(user: BattleActor, target: BattleActor) -> Dictionary:
	return {}

# Main logic for action.
# Returns message stating what happened to the targets. This is displayed for player.
func apply_effects(user: BattleActor, targets: Array) -> Dictionary:
	var end = ""
	if len(targets) == 1:
		if user == targets[0]:
			end = "itself"
		else:
			end =  targets[0].name
	else:
		end = "the opposing team"
	
	return { "msg": "%s used %s on %s." % [ user.name, name, end ] }

func apply_cost(user: BattleActor) -> float: 
	return 0

