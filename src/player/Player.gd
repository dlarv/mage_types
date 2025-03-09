extends CharacterBody3D 
class_name Player 

signal battle_started(allies, enemies)
signal dialog_started(dialog_id, enemy_actor, vendor_actor)

@export_category("Scene Nodes")
@export var battle_actor: BattleActor 
@export var team: Array[BattleActor]
@export var model: Node3D
@export var anim_player: AnimationPlayer

@export_category("Movement")
@export var walk_speed := 10.0
@export var run_speed := 30.0
var _is_running := false
## Is the player holding a Grabbable object.
var held_object: Node3D = null 
var restricted_axis := Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 25#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true
var outside_forces := Vector3.ZERO

var _god_mode := false
var _prev_collision_layer := collision_layer
var _prev_collision_mask := collision_mask

var player_name: 
	get:
		return battle_actor.name
	set(val):
		battle_actor.name = player_name

func _ready() -> void:
	team.insert(0, battle_actor)

func _unhandled_input(event: InputEvent) -> void:
	if not in_control: return
	if event.is_action_pressed("player_run"):
		_is_running = not _is_running
	elif event.is_action_pressed("toggle_god_mode"):
		_god_mode = not _god_mode
		if _god_mode:
			_prev_collision_layer = collision_layer
			_prev_collision_mask = collision_mask
			collision_layer = 0
			collision_mask = 0
		else:
			collision_layer = _prev_collision_layer
			collision_mask = _prev_collision_mask
	

func _physics_process(delta: float) -> void:
	if _god_mode: 
		_move_god_mode(delta)
		return
	if not in_control: 
		velocity = Vector3.ZERO
		return
	var vel = velocity
	var speed = walk_speed if not _is_running else run_speed

	# Add the gravity.
	if !is_on_floor():
		vel.y -= gravity * delta
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	if direction != Vector3.ZERO:
		# Player can only move along one axis.
		if restricted_axis != Vector3.ZERO:
			vel = restricted_axis * direction.dot(restricted_axis) * speed
		vel.x = direction.x * speed
		vel.z = direction.z * speed
		# Rotate model in direction of movement.
		if not held_object:
			model.rotation.y = atan2(vel.x, vel.z)
	else:
		vel.x = move_toward(velocity.x, 0, speed)
		vel.z = move_toward(velocity.z, 0, speed)


	velocity = vel + outside_forces
	outside_forces = Vector3.ZERO
	if vel == Vector3.ZERO:
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	move_and_slide()

func _move_god_mode(delta: float) -> void:
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	velocity = direction * run_speed * 2

	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += walk_speed
	elif Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= walk_speed

	move_and_slide()


func start_battle(npc: Variant) -> void:
	battle_started.emit(team, npc.enemy_actor)

func open_shop(npc: Variant) -> void:
	dialog_started.emit("VENDOR_MAIN", npc.enemy_actor, npc.vendor_actor)

func start_dialog(npc: Variant) -> void:
	dialog_started.emit(npc.story_actor.dialog_ids[npc.story_actor.current_id], npc.enemy_actor, npc.vendor_actor)

func pickup_object(obj: Node3D, grabbable: Grabbable, val: bool, axis:=Vector3.ZERO) -> void:
	if not val:
		held_object = null
		restricted_axis = Vector3.ZERO
		return
	held_object = obj
	
	grabbable.is_being_reparented = true
	obj.reparent(self)
	grabbable.is_being_reparented = false

	if axis != Vector3.ZERO:
		velocity = Vector3.ZERO
		restricted_axis = axis

func serialize() -> Dictionary:
	var teamData := []
	for t in team:
		teamData.append(t.serialize())
	return {
		"path": get_path(),
		"battle_actor": battle_actor.serialize(),
		"team": teamData,
		"position": global_position,
		"rotation": global_rotation,
		"model_rotation": model.global_rotation,
	}

func deserialize(data: Dictionary):
	if "position" in data:
		global_position = data["position"]
	if "rotation" in data:
		global_rotation = data["rotation"]
	if "model_rotation" in data:
		model.global_rotation = data["model_rotation"]
	if "battle_actor" in data:
		battle_actor.deserialize(data["battle_actor"])
	# if "team" in data:
	# 	team = []
	# 	for t in data["team"]:
	# 		team.append(BattleActor.new())
