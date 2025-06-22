@tool
extends MagiClay
class_name Golem

@export var delay_between_actions := 0.5
@export var base_walk_speed := 2.0
@export var base_turn_speed := 0.5

var battle_actor: BattleActor
var instructions := {}

var golem_name: String: 
	get:
		return "%s.%s" % [get_parent().get_parent().name, name]

var _active := false
var _curr_index := 0
var _timer := 0.0
var _accumulator := 0.0


func setup(actor: BattleActor, ins: Array) -> void:
	battle_actor = actor
	set_element(actor.element1)

	instructions = {}
	for instruction in ins:
		instructions[instruction.instruction] = instruction.value


func start() -> void:
	_timer = delay_between_actions
	_active = true


func _physics_process(delta: float) -> void:
	if not _active: return
	_timer += delta
	if _timer < delay_between_actions: return
	if _curr_index >= len(instructions.keys()):
		await get_tree().create_timer(1.0).timeout
		kill()
		return
		
	match instructions.keys()[_curr_index]:
		"WALK": step(delta)
		"TURN": turn(delta)
		"WAIT",_: 
			_accumulator += delta

	if _accumulator > instructions.values()[_curr_index]:
		_curr_index += 1
		_accumulator = 0
		_timer = 0


func step(delta: float) -> void:
	if _accumulator == 0:
		Logger.append_golem_log("Golem(%s) executing instruction: WALK %d steps." 
				% [golem_name, instructions.values()[_curr_index]])

	if self.velocity.x > 0.0 or self.velocity.z > 0.0:
		var s = self
		self.velocity.x = move_toward(self.velocity.x, 0, delta)
		self.velocity.z = move_toward(self.velocity.z, 0, delta)
		s.move_and_slide()
	else:
		_accumulator += 1
		self.velocity = basis.z.normalized() * base_walk_speed


func turn(delta: float) -> void:
	if _accumulator == 0:
		Logger.append_golem_log("Golem(%s) executed instruction: TURN %.2f degrees." 
				% [golem_name, instructions.values()[_curr_index]])

	var degrees: float = instructions.values()[_curr_index] * delta * base_turn_speed
	rotation_degrees.y += degrees
	_accumulator += degrees


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90
	_active = false
	process_mode = Node.PROCESS_MODE_DISABLED


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
	kill()


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
