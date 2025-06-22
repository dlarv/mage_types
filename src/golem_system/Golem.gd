@tool
extends MagiClay
class_name Golem

var battle_actor: BattleActor
var instructions := {}


func setup(actor: BattleActor, ins: Array) -> void:
	battle_actor = actor
	set_element(actor.element1)

	instructions = {}
	for instruction in ins:
		instructions[instruction.instruction] = instruction.value


func execute() -> void:
	for key in instructions:
		match key:
			"WALK": step(instructions[key])
			"TURN": turn(instructions[key])
			"WAIT": await get_tree().create_timer(instructions[key]).timeout
		await get_tree().create_timer(_speed_to_delay()).timeout


func step(num: int) -> void:
	pass


func turn(degrees: float) -> void:
	pass


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90


func deserialize(data: Dictionary) -> void:
	global_position = data.position
	global_rotation = data.rotation
	battle_actor.deserialize(data.battle_actor)
	set_element(battle_actor.element1)


func serialize() -> Dictionary:
	return {
		"is_golem": true,
		"position": global_position,
		"rotation": global_rotation,
		"battle_actor": battle_actor.serialize(),
	}

static func create() -> Golem:
	var output: Golem = load("res://src/golem_system/golem.tscn").instantiate()
	output.battle_actor = BattleActor.new()
	return output
