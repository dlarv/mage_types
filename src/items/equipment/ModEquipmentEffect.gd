@tool
extends _EquipmentEffect
class_name ModEquipmentEffect

enum Type { PREVENT_DEFEAT, TRAINING_WHEELS, HAMMER, NONE }

# This will act like a const. It will be setup by whichever BattleActor is first instantiated
static var TARGET_METHODS: Array[StringName] = []

@export var target_method: StringName:
	set(val):
		target_method = val
		print(val)
@export_multiline var source_code: String

var data: Dictionary[BattleActor, FuncHolder] = {}

func _init() -> void:
	if len(TARGET_METHODS) > 0: return

	var actor := PlayerBattleActor.new()

	TARGET_METHODS = [
		actor._apply_dmg.get_method(),
		actor.add_xp.get_method(),
		actor.setup.get_method(),
		actor.get_attack_stat.get_method(),
		actor.get_defense_stat.get_method(),
		actor.add_status_effect.get_method(),
		actor._calc_blocking.get_method(),
		actor.heal.get_method(),
		actor.resolve_end_of_turn.get_method(),
	]


func setup(actor: BattleActor) -> void:
	data[actor].setup(actor)


#virtual
func equip(actor: BattleActor) -> void: 
	if not actor.battle_setup_completed.is_connected(setup):
		actor.battle_setup_completed.connect(setup.bind(actor))
	
	data[actor] = FuncHolder.new(source_code)
	actor.add_func_override(target_method, data[actor].replace_method.bind(actor, self))


#virtual
func unequip(actor: BattleActor) -> void: 
	actor.battle_setup_completed.disconnect(setup)
	actor.remove_func_override(target_method)
	data.erase(actor)


class FuncHolder:
	var ref: RefCounted
	var replace_method: Callable
	var setup_method: Callable

	func _init(source_code:="") -> void:
		var script := GDScript.new()
		script = GDScript.new()
		script.set_source_code(source_code)
		assert(script.reload() == OK)

		ref = RefCounted.new()
		ref.set_script(script)

		if ref.has_method("execute"):
			replace_method = Callable(ref, "execute")
		if ref.has_method("setup"):
			setup_method = Callable(ref, "setup")


	func setup(actor: BattleActor) -> void:
		if ref.has_method("setup"):
			setup_method.call(actor)
