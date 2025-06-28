@tool
extends MagiClay
class_name Golem

const SNAP_VALUE := Vector3(0.5, 0, 0.5)
## If golem is walking into a wall for this many seconds, move onto next instruction.
const WALK_THRESHOLD := 2.0

@export var delay_between_actions := 0.5
@export var base_walk_speed := 2.0
@export var base_turn_speed := 0.5

var battle_actor: BattleActor
var instructions := []
var outside_forces := Vector3.ZERO
var golem_name: String
var parent_chunk: Chunk

var _initial_position: Vector3
var _target_position: Vector3
var _step_start_position: Vector3
var _active := false
var _curr_index := 0
var _timer := 0.0
var _accumulator := -1.0
# How many loads until corpse disappears.
var _decomposition_counter := 3
# If golem is floating at top of geyser, move on to next instruction.
var pause_gravity := false


func setup(actor: BattleActor, ins: Array) -> void:
	battle_actor = actor
	set_element(actor.element1)

	instructions = []
	for instruction in ins:
		if instruction.instruction == "WALK":
			for i in instruction.value:
				instructions.append(["WALK", 1])
			continue

		instructions.append([instruction.instruction, instruction.value])


func start() -> void:
	global_position = global_position.snapped(SNAP_VALUE)
	_initial_position = global_position
	_timer = 0
	_active = true


func _physics_process(delta: float) -> void:
	if not _active or in_stasis: return
	_timer += delta
	if _timer < delay_between_actions: return
	var s = self
	if _curr_index >= len(instructions):
		if not s.is_on_floor():
			kill_and_remove()
		else:
			await get_tree().create_timer(1.0).timeout
			kill()
		return
		
	match instructions[_curr_index][0]:
		"WALK": step(delta)
		"TURN": turn(delta)
		"GOTO": goto()
		"AGAIN":
			again()
		"WAIT",_: 
			if _accumulator == -1:
				_accumulator = 0
			_accumulator += delta
	
	move(delta)

	if _evaluate():
		_curr_index += 1
		_accumulator = -1
		_timer = 0


func move(delta: float, onlyGravity:=false) -> void:
	if not element == ElementManager.Yellow and not pause_gravity:
		self.velocity.y += get_local_gravity() * delta
	var s = self
	if onlyGravity: 
		if s.move_and_slide():
			_push_objects()
		return

	self.velocity += outside_forces * delta
	outside_forces = Vector3.ZERO

	if s.move_and_slide():
		_push_objects()


func step(delta: float) -> void:
	if _accumulator > instructions[_curr_index][1]:
		return

	var speed := basis.z.normalized()
	if _accumulator == -1:
		Logger.append_golem_log("Golem(%s) executing instruction: WALK %d steps." 
				% [golem_name, instructions[_curr_index][1]])
		self.velocity = Vector3.ZERO
		_step_start_position = global_position
		_target_position = global_position + speed

	var dist := _step_start_position - global_position
	dist.y = 0
	_accumulator = dist.length()

	if _accumulator > instructions[_curr_index][1]:
		self.velocity = Vector3.ZERO
		pause_gravity = false
		if outside_forces == Vector3.ZERO:
			var yPos := global_position.y
			global_position = _target_position.snapped(SNAP_VALUE)
			global_position.y = yPos
	else:
		speed *= base_walk_speed
		self.velocity = speed


func turn(delta: float) -> void:
	if _accumulator == -1:
		Logger.append_golem_log("Golem(%s) executed instruction: TURN(%.2f)." 
				% [golem_name, instructions[_curr_index][1]])
		_accumulator = 0

	var degrees: float = instructions[_curr_index][1] * delta * base_turn_speed
	rotation_degrees.y += degrees
	_accumulator += degrees


func goto() -> void:
	if instructions[_curr_index][1] >= len(instructions):
		_curr_index = len(instructions) - 1
		Logger.append_golem_log("Golem(%s) executed instruction: GOTO(%d)(out of bounds) => GOTO(%d)(actual)." 
				% [golem_name, len(instructions) - 1, int(instructions[_curr_index][1])])
	else:
		_curr_index = instructions[_curr_index][1]
		Logger.append_golem_log("Golem(%s) executed instruction: GOTO(%d)." 
				% [golem_name, int(instructions[_curr_index][1])])

	# Reset values
	_accumulator = 0
	_timer = 0


func again() -> void:
	# Reset values
	_curr_index = 0
	_accumulator = -1
	_timer = 0

	global_position = _initial_position
	Logger.append_golem_log("Golem(%s) executed instruction: AGAIN." % golem_name) 


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90
	_active = false
	$CollisionShape3D.disabled = true
	$CollisionShape3D2.disabled = true

	if self.velocity.length() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED


func kill_and_remove() -> void:
	parent_chunk.remove_golem(self)


func instructions_to_string() -> String:
	var output := []
	for instr in instructions:
		output.append("%s:%.2f" % [instr[0], instr[1]])
	return ",".join(output)


func add_force(force: Vector3) -> void:
	outside_forces += force



func get_local_gravity() -> float:
	return -70


func deserialize(data: Dictionary) -> void:
	global_position = data.position
	global_rotation = data.rotation
	battle_actor.deserialize(data.battle_actor)
	set_element(battle_actor.element1)
	_decomposition_counter = data.decomposition_counter - 1
	if _decomposition_counter > 0:
		kill()
	else:
		kill_and_remove()


func serialize() -> Dictionary:
	return {
		"is_golem": true,
		"position": global_position,
		"rotation": global_rotation,
		"battle_actor": battle_actor.serialize(),
		"decomposition_counter": _decomposition_counter,
	}


static func create() -> Golem:
	var output: Golem = load("res://src/golem_system/golem.tscn").instantiate()
	output.battle_actor = BattleActor.new()
	return output


func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if not super.set_element(e, randVal, force): return false
	match element:
		ElementManager.Blue: set_collision_layer_value(7, false)
	return true


func fall_in_water() -> void:
	kill_and_remove()


func _push_objects() -> void:
	var s = self
	for i in s.get_slide_collision_count():
		var collision: KinematicCollision3D = s.get_slide_collision(i)
		var collider := collision.get_collider()
		if not collider.get_collision_layer_value(3) and not collider.get_collision_layer_value(6): continue
		if collider is RigidBody3D:
			collider.apply_force(collision.get_normal() * -500)
			self.velocity = basis.z.normalized() * base_walk_speed
		elif collider is CharacterBody3D:
			self.velocity = basis.z.normalized() * base_walk_speed
			collider.add_force(collision.get_normal() * -500)


func _evaluate() -> bool:
	var s = self
	var instruction: String = instructions[_curr_index][0] 
	var threshold: int = instructions[_curr_index][1] 
	return (_accumulator > threshold or (instruction == "WALK" and _timer > WALK_THRESHOLD)) \
			and ((s.is_on_floor() and self.velocity.length() == 0) or pause_gravity)
