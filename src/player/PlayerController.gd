extends Player

@export var walk_speed := 600.0
@export var run_speed := 800.0
@export var drag_speed := 500.0

@export var jump_height := 10.0
@export var jump_time_to_peak := 2.0
@export var jump_time_to_descent := 0.1

@onready var jump_velocity := 2.0 * jump_height / jump_time_to_peak
@onready var jump_gravity := (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)      
@onready var fall_gravity := (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
 
var _is_running := false
var draggable = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = -980#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true
var outside_forces := Vector3.ZERO

var _god_mode := false
var _god_mode_speed_mod := 3.0
var _prev_collision_layer := collision_layer
var _prev_collision_mask := collision_mask

func _unhandled_input(event: InputEvent) -> void:
	if not in_control: return
	if event.is_action_pressed("player_run"):
		_is_running = not _is_running
	elif event.is_action_pressed("toggle_god_mode"):
		_god_mode = not _god_mode
		if _god_mode:
			_prev_collision_layer = collision_layer
			_prev_collision_mask = collision_mask
			collision_layer = 32
			collision_mask = 0
		else:
			collision_layer = _prev_collision_layer
			collision_mask = _prev_collision_mask


func _physics_process(delta: float) -> void:
	if _god_mode: 
		_move_god_mode(delta)
		return
	if draggable != null:
		_move_drag_mode(delta)
		return

	var speed := walk_speed if not _is_running else run_speed

	# Add the gravity.
	velocity.y += _get_gravity() * delta

	if self.is_on_floor()and Input.is_action_pressed("jump"):
		velocity.y = jump_velocity
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed * delta
		velocity.z = direction.z * speed * delta
		# Rotate model in direction of movement.
		model.rotation.y = atan2(velocity.x, velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.z = move_toward(velocity.z, 0, speed * delta)

	velocity += outside_forces * delta
	outside_forces = Vector3.ZERO
	if velocity.x == 0 and velocity.z == 0: 
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	move_and_slide()


func _get_gravity() -> float:
	return jump_gravity if velocity.y > 0.0 else fall_gravity


func _move_god_mode(delta: float) -> void:
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	var speedMod := _god_mode_speed_mod
	if Input.is_key_pressed(KEY_CTRL):
		speedMod *= 3

	velocity = direction * run_speed * speedMod * delta

	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += walk_speed / 2 * speedMod * delta
	elif Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= walk_speed * delta * speedMod

	move_and_slide()


func _move_drag_mode(delta: float) -> void:
	if Input.is_action_pressed("ui_up") and draggable.current_axis.z > 0:
		velocity.z -= drag_speed / draggable.weight
	elif Input.is_action_pressed("ui_down") and draggable.current_axis.z > 0:
		velocity.z += drag_speed / draggable.weight
	elif Input.is_action_pressed("ui_left") and draggable.current_axis.x > 0:
		velocity.x -= drag_speed / draggable.weight
	elif Input.is_action_pressed("ui_right") and draggable.current_axis.x > 0:
		velocity.x += drag_speed / draggable.weight
	
	velocity.y += _get_gravity() * 5
	velocity *= delta

	# Snap to grid.
	if velocity.length() < 0.1:
		var yPos := global_position.y
		global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))
		global_position.y = yPos
	else:
		move_and_slide()


func add_force(force: Vector3) -> void:
	outside_forces += force


func try_set_draggable(obj: Node3D) -> bool:
	if draggable != null: return false
	elif not is_on_floor(): return false
	draggable = obj
	return true
