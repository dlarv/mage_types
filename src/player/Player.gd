extends MagiClay
class_name Player 

signal battle_started(allies, enemies)
signal dialog_started(dialog_id, npc)
signal cutscene_started(player: AnimationPlayer, id: String)

@export_category("Scene Nodes")
@export var battle_actor: BattleActor
@export var team: Array[BattleActor]
@export var model: Node3D
@export var anim_player: AnimationPlayer

@export_category("Movement")
@export var walk_speed := 600.0
@export var run_speed := 800.0
@export var drag_speed := 500.0
var _is_running := false
var draggable = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 980#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
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
	if not battle_actor in team:
		team.insert(0, battle_actor)
	
	player_name = Settings.player_name
	Settings.player_name_changed.connect(func(name):
		player_name = name)

	model.get_active_material(0).albedo_color = battle_actor.element1.main_color
	model.get_active_material(1).albedo_color = battle_actor.element2.main_color
	battle_actor.element_changed.connect(_on_battle_actor_element_changed)


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
	if is_dragging():
		_move_drag_mode(delta)
		return
	var vel = self.velocity
	var speed = walk_speed if not _is_running else run_speed

	# Add the gravity.
	var s = self
	if !s.is_on_floor() and outside_forces.y == 0:
		vel.y -= gravity
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	if direction != Vector3.ZERO:
		vel.x = direction.x * speed
		vel.z = direction.z * speed
		# Rotate model in direction of movement.
		model.rotation.y = atan2(vel.x, vel.z)
	else:
		vel.x = move_toward(self.velocity.x, 0, speed)
		vel.z = move_toward(self.velocity.z, 0, speed)

	self.velocity = (vel + outside_forces) * delta
	outside_forces = Vector3.ZERO
	if vel == Vector3.ZERO:
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	s.move_and_slide()


func _move_god_mode(delta: float) -> void:
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	var speedMod := 2.0
	if Input.is_key_pressed(KEY_CTRL):
		speedMod *= 3

	self.velocity = direction * run_speed * speedMod * delta

	if Input.is_key_pressed(KEY_SPACE):
		self.velocity.y += walk_speed / 2 * speedMod * delta
	elif Input.is_key_pressed(KEY_SHIFT):
		self.velocity.y -= walk_speed * delta

	var s = self
	s.move_and_slide()


func _move_drag_mode(delta: float) -> void:
	if Input.is_action_pressed("ui_up") and draggable.current_axis.z > 0:
		self.velocity.z -= drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_down") and draggable.current_axis.z > 0:
		self.velocity.z += drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_left") and draggable.current_axis.x > 0:
		self.velocity.x -= drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_right") and draggable.current_axis.x > 0:
		self.velocity.x += drag_speed * draggable.weight
	
	self.velocity *= delta

	# Snap to grid.
	if self.velocity.length() < 0.1:
		global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))
		draggable.parent.global_position = draggable.parent.global_position.snapped(Vector3(0.5, 0.5, 0.5))
	else:
		var s = self
		s.move_and_slide()


func start_battle(npc: Variant) -> void:
	battle_started.emit(team, npc.enemy_actor)


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


func react(element: ElementalType, randVal:=-2) -> bool:
	if randVal == _rand_val: return false
	_rand_val = randVal

	var e1 := ElementManager.get_matchup(battle_actor.element1, element)
	if e1:
		battle_actor.set_element(0, e1)

	var e2 := ElementManager.get_matchup(battle_actor.element2, element)
	if e2:
		battle_actor.set_element(1, e2)
	return true

func _on_battle_actor_element_changed(id: int, element: ElementalType) -> void:
		model.get_active_material(id).albedo_color = element.main_color

func _get_mesh() -> MeshInstance3D:
	return model
