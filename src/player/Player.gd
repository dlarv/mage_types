extends CharacterBody3D 
class_name Player 

signal pause_world(val: bool)
signal battle_started(allies, enemies)
signal dialog_started(dialog_id, enemy_actor, vendor_actor)

@export_category("Scene Nodes")
@export var battle_actor: BattleActor 
@export var team: Array[BattleActor]
@export var player_menu: Control 
@export var model: Node3D
@export var anim_player: AnimationPlayer

@export_category("Movement")
@export var walk_speed := 10.0
@export var run_speed := 30.0
var _is_running := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 25#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true

func _ready() -> void:
	team.insert(0, battle_actor)
	player_menu.pause_world.connect(func(value): 
		in_control = value
		pause_world.emit(value))

func _unhandled_input(event: InputEvent) -> void:
	if not in_control: return
	if event.is_action_pressed("player_run"):
		_is_running = not _is_running
	

func _physics_process(delta) -> void:
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
		vel.x = direction.x * speed
		vel.z = direction.z * speed
		# Rotate model in direction of movement.
		model.rotation.y = atan2(vel.x, vel.z)
	else:
		vel.x = move_toward(velocity.x, 0, speed)
		vel.z = move_toward(velocity.z, 0, speed)


	velocity = vel
	if vel == Vector3.ZERO:
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	move_and_slide()

func start_battle(npc: Variant) -> void:
	battle_started.emit(team, npc.enemy_actor)

func open_shop(npc: Variant) -> void:
	dialog_started.emit("VENDOR_MAIN", npc.enemy_actor, npc.vendor_actor)

func start_dialog(npc: Variant) -> void:
	dialog_started.emit(npc.story_actor.dialog_ids[npc.story_actor.current_id], npc.enemy_actor, npc.vendor_actor)
