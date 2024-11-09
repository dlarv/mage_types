extends RigidBody3D
class_name PhysicsPlayer

signal battle_started(allies, items, enemies)

@export_category("Scene Nodes")
@export var battle_actor: BattleActor 
@export var team: Array[BattleActor]
@export var player_menu: Control 
@export var model: Node3D

@export_category("Movement")
@export var walk_speed := 10.0
@export var run_speed := 30.0
@export var jump_speed := 10.0
var _is_running := false
var _is_grounded := true
var projectile_manager: Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 25#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true

func _ready() -> void:
	team.insert(0, battle_actor)
	projectile_manager = find_child("ProjectileManager", true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_god_camera"):
		switch_to_god_camera(in_control)

	if not in_control: return
	if event.is_action_pressed("player_run"):
		_is_running = not _is_running

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var inputDir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var jump := Input.is_key_label_pressed(KEY_SPACE)

	var speed := walk_speed if not _is_running else run_speed
	var airMod := .3 if not _is_grounded else 1.0

	var direction := (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var velocity := Vector3(
			clampf(inputDir.x * airMod + state.linear_velocity.x, -speed, speed),
			state.linear_velocity.y, 
			clampf(inputDir.y * airMod + state.linear_velocity.z, -speed, speed))

	if jump_speed > 0 and jump and _is_grounded:
		velocity.y += jump_speed
		_is_grounded = false

	if direction != Vector3.ZERO:
		# Rotate model in direction of movement.
		model.rotation.y = atan2(inputDir.x, inputDir.y)

	state.linear_velocity = velocity
	
func start_battle(enemies: EnemyActor) -> void:
	battle_started.emit(team, Inventory.get_battle_items(), enemies)

func switch_to_god_camera(value := true) -> void:
	GodCamera.in_control = value
	GodCamera.current = value
	in_control = not value
	$Camera3D.current = not value

func _on_body_entered(body: Node3D) -> void:
	if not _is_grounded and body.get_collision_layer_value(1):
		_is_grounded = true


