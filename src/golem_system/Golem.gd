@tool
extends MagiClay
class_name Golem

var battle_actor: BattleActor
var instructions := {}

func setup(actor: BattleActor, ins: Array) -> void:
	battle_actor = actor

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
	return battle_actor.speed
