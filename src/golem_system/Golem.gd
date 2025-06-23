@tool
extends MagiClay
class_name Golem

@export var delay_between_actions := 0.5
@export var base_walk_speed := 2.0
@export var base_turn_speed := 0.5

var battle_actor: BattleActor
var instructions := []
var outside_forces := Vector3.ZERO

var golem_name: String

var _active := false
var _curr_index := 0
var _timer := 0.0
var _accumulator := 0.0


func setup(actor: BattleActor, ins: Array) -> void:
	battle_actor = actor
	set_element(actor.element1)

	instructions = []
	for instruction in ins:
		instructions.append([instruction.instruction, instruction.value])


func start() -> void:
	_timer = delay_between_actions
	_active = true


func _physics_process(delta: float) -> void:
	if not _active: return
	_timer += delta
	if _timer < delay_between_actions: return
	if _curr_index >= len(instructions):
		var s = self
		if not s.is_on_floor():
			kill_and_remove()
		else:
			await get_tree().create_timer(1.0).timeout
			kill()
		return
		
	match instructions[_curr_index][0]:
		"WALK": step(delta)
		"TURN": turn(delta)
		"WAIT",_: 
			_accumulator += delta
	
	move(delta)

	if _accumulator > instructions[_curr_index][1]:
		_curr_index += 1
		_accumulator = 0
		_timer = 0

func move(delta: float, onlyGravity:=false) -> void:
	self.velocity.y += _get_gravity() * delta
	var s = self
	if onlyGravity: 
		s.move_and_slide()
		return

	self.velocity += outside_forces * delta
	outside_forces = Vector3.ZERO

	self.velocity.x = move_toward(self.velocity.x, 0, delta)
	self.velocity.z = move_toward(self.velocity.z, 0, delta)
	s.move_and_slide()


func step(delta: float) -> void:
	if _accumulator == 0:
		Logger.append_golem_log("Golem(%s) executing instruction: WALK %d steps." 
				% [golem_name, instructions[_curr_index][1]])
		self.velocity = Vector3.ZERO

	if self.velocity.x != 0.0 or self.velocity.z != 0.0:
		pass
	else:
		_accumulator += 1
		self.velocity = basis.z.normalized() * base_walk_speed


func turn(delta: float) -> void:
	if _accumulator == 0:
		Logger.append_golem_log("Golem(%s) executed instruction: TURN %.2f degrees." 
				% [golem_name, instructions[_curr_index][1]])

	var degrees: float = instructions[_curr_index][1] * delta * base_turn_speed
	rotation_degrees.y += degrees
	_accumulator += degrees


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90
	_active = false

	if self.velocity.length() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED

func kill_and_remove() -> void:
	get_parent().get_parent().remove_golem(self)

func instructions_to_string() -> String:
	var output := []
	for instr in instructions:
		output.append("%s:%.2f" % [instr[0], instr[1]])
	return ",".join(output)


func add_force(force: Vector3) -> void:
	outside_forces += force


func _get_gravity() -> float:
	return -70


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
