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

var active := false
var curr_index := 0
var timer := 0.0
var accumulator := -1.0

var _initial_position: Vector3
var _target_position: Vector3
var _step_start_position: Vector3
var _start_rotation: float

# How many loads until corpse disappears.
var _decomposition_counter := 3
var _reached_top_of_geyser := false
# Used to preserve velocity after a collision steals momentum.
var _prev_velocity: Vector3


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
	timer = 0
	active = true


func _physics_process(delta: float) -> void:
	if not active or in_stasis: return
	timer += delta
	if timer < delay_between_actions: return
	var s = self
	if curr_index >= len(instructions):
		if not s.is_on_floor():
			kill_and_remove()
		else:
			await get_tree().create_timer(1.0).timeout
			kill()
		return
		
	match instructions[curr_index][0]:
		"WALK": step(delta)
		"TURN": turn(delta)
		"GOTO": goto()
		"AGAIN":
			again()
		"WAIT",_: 
			if accumulator == -1:
				accumulator = 0
			accumulator += delta
	
	move(delta)

	if s.is_on_floor():
		_reached_top_of_geyser = false

	if _evaluate():
		curr_index += 1
		accumulator = -1
		timer = 0


func move(delta: float, onlyGravity:=false) -> void:
	if not element == ElementManager.Yellow:
		self.velocity.y += get_local_gravity() * delta
	var s = self
	if onlyGravity: 
		if s.move_and_slide():
			_push_objects()
		return

	self.velocity += outside_forces * delta
	_prev_velocity = self.velocity

	if s.move_and_slide():
		_push_objects()
	outside_forces = Vector3.ZERO
	_prev_velocity = Vector3.ZERO


func step(delta: float) -> void:
	if accumulator > instructions[curr_index][1]:
		return

	var speed := basis.z.normalized()
	if accumulator == -1:
		Logger.append_golem_log("Golem(%s) executing instruction: WALK %d steps." 
				% [golem_name, instructions[curr_index][1]])
		self.velocity = Vector3.ZERO
		_step_start_position = global_position
		_step_start_position.y = 0
		_target_position = global_position + speed
		_target_position.y = 0

	var dist := _step_start_position - global_position
	dist.y = 0
	accumulator = dist.length()

	if accumulator > instructions[curr_index][1]:
		self.velocity = Vector3.ZERO
		# pause_gravity = false
		if outside_forces == Vector3.ZERO:
			var yPos := global_position.y
			global_position = _target_position.snapped(SNAP_VALUE)
			global_position.y = yPos
	else:
		speed *= base_walk_speed
		self.velocity = speed


func turn(delta: float) -> void:
	if accumulator == -1:
		Logger.append_golem_log("Golem(%s) executed instruction: TURN(%.2f)." 
				% [golem_name, instructions[curr_index][1]])
		accumulator = 0
		_start_rotation = rotation_degrees.y

	var degrees: float = instructions[curr_index][1] * delta * base_turn_speed
	rotation_degrees.y = min(degrees + rotation_degrees.y, instructions[curr_index][1] + _start_rotation)
	accumulator += degrees


func goto() -> void:
	if instructions[curr_index][1] >= len(instructions):
		curr_index = len(instructions) - 1
		Logger.append_golem_log("Golem(%s) executed instruction: GOTO(%d)(out of bounds) => GOTO(%d)(actual)." 
				% [golem_name, len(instructions) - 1, int(instructions[curr_index][1])])
	else:
		curr_index = instructions[curr_index][1]
		Logger.append_golem_log("Golem(%s) executed instruction: GOTO(%d)." 
				% [golem_name, int(instructions[curr_index][1])])

	# Reset values
	accumulator = 0
	timer = 0


func again() -> void:
	# Reset values
	curr_index = 0
	accumulator = -1
	timer = 0

	global_position = _initial_position
	Logger.append_golem_log("Golem(%s) executed instruction: AGAIN." % golem_name) 


func _speed_to_delay() -> float:
	return 1.0#battle_actor.speed


func kill() -> void:
	rotation_degrees.x = 90
	active = false
	$HeadCollisionShape.disabled = true
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

		var norm := collision.get_normal().normalized()
		var dir := global_position.direction_to(_target_position)
		dir.y = outside_forces.y
		dir = dir.normalized()
		var dot: float = abs(norm.dot(dir))

		if dot < 0.5: continue 

		var amount := -500 if element == ElementManager.Magenta else -100
		if collider is RigidBody3D:
			self.velocity = _prev_velocity
			collider.apply_force(collision.get_normal() * amount)
		elif collider is CharacterBody3D:
			self.velocity = _prev_velocity
			collider.add_force(collision.get_normal() * amount)


func _evaluate() -> bool:
	var s = self
	var instruction: String = instructions[curr_index][0] 
	var threshold: int = instructions[curr_index][1] 
	var reachedTop := _reached_top_of_geyser
	_reached_top_of_geyser = false
	return (accumulator > threshold or (instruction == "WALK" and timer > WALK_THRESHOLD)) \
			and ((s.is_on_floor() and self.velocity.length() == 0) or reachedTop)

func reached_top_of_geyser() -> void:
	_reached_top_of_geyser = true
