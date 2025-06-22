@tool
extends MagiClay
class_name Golem

var battle_actor: BattleActor
var instructions := {}

var golem_name: String: 
	get:
		return "%s.%s" % [get_parent().get_parent().name, name]


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
			"WAIT": 
				Logger.append_golem_log("Golem(%s) executed instruction: WAIT %.2f seconds." 
						% [golem_name, instructions[key]])
				await get_tree().create_timer(instructions[key]).timeout
		await get_tree().create_timer(_speed_to_delay()).timeout


func step(steps: int) -> void:
	Logger.append_golem_log("Golem(%s) executed instruction: WALK %d steps." % [golem_name, steps])


func turn(degrees: float) -> void:
	Logger.append_golem_log("Golem(%s) executed instruction: TURN %.2f degrees." % [golem_name, degrees])


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90


func instructions_to_string() -> String:
	var output := []
	for instr in instructions:
		output.append("%s:%.2f" % [instr, instructions[instr]])
	return ",".join(output)


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
