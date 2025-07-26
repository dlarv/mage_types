extends RigidBody3D
class_name PhysicsPlayer
@warning_ignore_start("untyped_declaration")

signal battle_started(allies, enemies)
signal dialog_started(dialog_id, npc)
signal cutscene_started(player: AnimationPlayer, id: String)

@export_category("Scene Nodes")
@export var battle_actor: BattleActor 
@export var team: Array[BattleActor]
@export var model: Node3D
@export var anim_player: AnimationPlayer

@export_category("Movement")
@export var walk_speed := 10.0
@export var run_speed := 20.0
var _is_running := false
var draggable = null 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 25#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true
var player_name: 
	get:
		return battle_actor.name
	set(val):
		battle_actor.name = player_name

var _god_mode := false
var _prev_collision_layer := collision_layer
var _prev_collision_mask := collision_mask


func _ready() -> void:
	if not battle_actor in team:
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


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _god_mode:
		_move_god_mode(state)
		return
	elif is_dragging():
		_move_drag_mode(state)
		return

	var inputDir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var speed := walk_speed if not _is_running else run_speed

	var direction := Vector3(inputDir.x, 0, inputDir.y).normalized()
	var velocity := direction * speed
	velocity.y = state.linear_velocity.y

	if direction != Vector3.ZERO:
		# Rotate model in direction of movement.
		model.rotation.y = atan2(inputDir.x, inputDir.y)

	state.linear_velocity = velocity


func _move_god_mode(state: PhysicsDirectBodyState3D) -> void:
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(inputDir.x, 0, inputDir.y).normalized()
	state.linear_velocity = direction * run_speed * 2

	if Input.is_key_pressed(KEY_SPACE):
		state.linear_velocity.y += walk_speed 
	elif Input.is_key_pressed(KEY_SHIFT):
		state.linear_velocity.y -= walk_speed


func _move_drag_mode(state: PhysicsDirectBodyState3D) -> void:
	var velocity := Vector3.ZERO

	if Input.is_action_pressed("ui_up") and draggable.current_axis.z > 0:
		velocity.z -= draggable.drag_speed
	elif Input.is_action_pressed("ui_down") and draggable.current_axis.z > 0:
		velocity.z += draggable.drag_speed
	elif Input.is_action_pressed("ui_left") and draggable.current_axis.x > 0:
		velocity.x -= draggable.drag_speed
	elif Input.is_action_pressed("ui_right") and draggable.current_axis.x > 0:
		velocity.x += draggable.drag_speed

	# Snap to grid.
	draggable.move(velocity)
	if velocity == Vector3.ZERO:
		global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))
	else:
		state.linear_velocity = velocity


func start_battle(enemies: EnemyActor) -> void:
	battle_started.emit(team, enemies)


func open_shop(npc: Variant) -> void:
	dialog_started.emit("VENDOR_MAIN", npc)


func start_dialog(npc: Variant) -> void:
	var id = npc.get_next_dialog_id()
	if len(id) == 0: return
	dialog_started.emit(id, npc)


func play_cutscene(player: AnimationPlayer, id: String) -> void:
	cutscene_started.emit(player, id)


func look_towards(point: Vector3, yOnly := true) -> void:
	if yOnly:
		point.y = model.global_position.y
	model.look_at(point)
	# Model is facing the opposite way, so correct.
	model.global_rotation_degrees.y += 180


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

func is_dragging() -> bool:
	return draggable != null

func set_draggable(obj: Node3D) -> void:
	draggable = obj
