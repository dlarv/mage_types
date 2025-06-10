extends Player

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
	if is_dragging():
		_move_drag_mode(delta)
		return

	var vel := velocity
	var speed := walk_speed if not _is_running else run_speed

	if self.is_on_floor():
		if Input.is_action_pressed("jump"):
			vel.y += 15000
	else:
		# Add the gravity.
		if outside_forces.y == 0:
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
		vel.x = move_toward(velocity.x, 0, speed)
		vel.z = move_toward(velocity.z, 0, speed)

	velocity = (vel + outside_forces) * delta
	outside_forces = Vector3.ZERO
	if vel == Vector3.ZERO:
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	move_and_slide()


func _move_god_mode(delta: float) -> void:
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	var speedMod := 2.0
	if Input.is_key_pressed(KEY_CTRL):
		speedMod *= 3

	velocity = direction * run_speed * speedMod * delta

	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += walk_speed / 2 * speedMod * delta
	elif Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= walk_speed * delta

	move_and_slide()


func _move_drag_mode(delta: float) -> void:
	if Input.is_action_pressed("ui_up") and draggable.current_axis.z > 0:
		velocity.z -= drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_down") and draggable.current_axis.z > 0:
		velocity.z += drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_left") and draggable.current_axis.x > 0:
		velocity.x -= drag_speed * draggable.weight
	elif Input.is_action_pressed("ui_right") and draggable.current_axis.x > 0:
		velocity.x += drag_speed * draggable.weight
	
	velocity *= delta

	# Snap to grid.
	if velocity.length() < 0.1:
		var yPos := global_position.y
		global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))
		global_position.y = yPos
		# global_position.y = draggable.parent.global_position.y
		# draggable.parent.global_position = draggable.parent.global_position.snapped(Vector3(0.5, 0.5, 0.5))
		# draggable.parent.global_position.y = yPos
	else:
		move_and_slide()


func is_dragging() -> bool:
	return draggable != null


func set_draggable(obj: Node3D) -> void:
	draggable = obj


