extends "Player.gd"

const MAX_FREEFALL_DIST := -40.0

@export var walk_speed := 700.0
@export var draggable_speed := 500.0
@export var friction := 0.9

@export var jump_height := 1.0
@export var jump_time_to_peak := 0.4
@export var jump_time_to_descent := 0.3
@export var coyote_time_length := 0.5
@export var keep_jump_buffer_length := 0.1
@export var variable_jump_height_modifier := 15.0
@export var variable_jump_time_window := 0.3 
@export var dash_speed := 1200.0
@export var sprint_speed := 1000.0

@onready var jump_velocity := 2.0 * jump_height / jump_time_to_peak
@onready var jump_gravity := (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)      
@onready var fall_gravity := (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

var dash_tween: Tween
var dash_velocity: float
var _can_air_dash := true
 
var draggable: Node3D = null
var last_grounded_position: Vector3

var _can_jump := true
var _jump_buffer := false
var _jump_timer := 0.0
var _jump_strength := 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := -980#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle()
var in_control := true
var outside_forces := Vector3.ZERO

var _god_mode := false
var _god_mode_speed_mod := 3.0
var _prev_collision_layer := collision_layer
var _prev_collision_mask := collision_mask

func _ready() -> void:
	super._ready()
	$CoyoteTimer.wait_time = coyote_time_length
	$FlushJumpBufferTimer.wait_time = keep_jump_buffer_length


func _unhandled_input(event: InputEvent) -> void:
	if not in_control: return
	if event.is_action_pressed("dash"):
		# _is_running = not _is_running
		pass
	elif event.is_action_pressed("toggle_god_mode"):
		_god_mode = not _god_mode
		_toggle_3d_collision_shape_visibility()
		if _god_mode:
			_prev_collision_layer = collision_layer
			_prev_collision_mask = collision_mask
			collision_layer = 32
			collision_mask = 0
		else:
			collision_layer = _prev_collision_layer
			collision_mask = _prev_collision_mask
		get_viewport().set_input_as_handled()
	elif not _god_mode and not draggable:
		if event.is_action_pressed("jump"):
			_jump_buffer = true
			$FlushJumpBufferTimer.start()


func _physics_process(delta: float) -> void:
	if _god_mode: 
		_move_god_mode(delta)
		return
	if global_position.y <= MAX_FREEFALL_DIST and not is_on_floor():
		velocity.y = 0
		fall_in_water()
	if draggable != null:
		_move_drag_mode(delta)
		return

	if is_on_floor():
		_can_jump = true
		_jump_strength = 0
		_jump_timer = 0
		_can_air_dash = true
		
		if $GroundedTimer.is_stopped():
			last_grounded_position = global_position
			$GroundedTimer.start()

	# Add the gravity.
	velocity.y += get_local_gravity() * delta
	velocity.x *= friction
	velocity.z *= friction

	# Variable jump height
	if Input.is_action_just_pressed("jump"):
		_jump_strength = variable_jump_height_modifier
	# Prevent player from jumping, releasing button, then pressing it again (feels off).
	if Input.is_action_just_released("jump"):
		_jump_timer = variable_jump_time_window
	else:
		_jump_timer += delta
	if _jump_timer < variable_jump_time_window:
		velocity.y += _jump_strength * delta
	
	var speed := walk_speed
	if Input.is_action_pressed("dash"):
		speed = sprint_speed

	if _can_dash() and Input.is_action_just_pressed("dash"):
		if not is_on_floor() and _can_air_dash:
			_can_air_dash = false
			velocity.y = 0
		dash_velocity = dash_speed
		dash_tween = create_tween()
		dash_tween.tween_interval(0.1)
		dash_tween.tween_property(self, "dash_velocity", 0, 0.1).set_ease(Tween.EASE_OUT)

	# Jumping, while accounting for coyote time.
	elif _can_jump and dash_velocity <= dash_speed / 3:
		if _jump_buffer:
			velocity.y = jump_velocity
			_can_jump = false
			_jump_buffer = false
		if not is_on_floor() and $CoyoteTimer.is_stopped():
			$CoyoteTimer.start()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * (speed + dash_velocity) * delta
		velocity.z = direction.z * (speed + dash_velocity) * delta
		# Rotate model in direction of movement.
		model.rotation.y = atan2(velocity.x, velocity.z)
	elif dash_velocity > 0:
		velocity.x = move_toward(
			velocity.x, 
			model.basis.z.normalized().x * (walk_speed + dash_velocity) * delta, 
			walk_speed * delta)
		velocity.z = move_toward(
			velocity.z, 
			model.basis.z.normalized().z * (walk_speed + dash_velocity) * delta, 
			walk_speed * delta)
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


func get_local_gravity() -> float:
	# Don't fall while dashing.
	if dash_tween and dash_tween.is_valid(): return 0.0 #and dash_tween.is_running(): return 0.0
	return jump_gravity if velocity.y > 0.0 else fall_gravity

func _can_dash() -> bool:
	return (not dash_tween or not dash_tween.is_valid()) and (is_on_floor() or _can_air_dash)


func _move_god_mode(delta: float) -> void:
	var inputDir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	var speedMod := _god_mode_speed_mod
	if Input.is_key_pressed(KEY_CTRL):
		speedMod *= 3

	velocity = direction * walk_speed * speedMod * delta

	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += walk_speed / 2 * speedMod * delta
	elif Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= walk_speed * delta * speedMod

	move_and_slide()


func _move_drag_mode(delta: float) -> void:
	if Input.is_action_pressed("ui_up") and draggable.current_axis.z > 0:
		velocity.z -= draggable_speed / draggable.weight
	elif Input.is_action_pressed("ui_down") and draggable.current_axis.z > 0:
		velocity.z += draggable_speed / draggable.weight
	elif Input.is_action_pressed("ui_left") and draggable.current_axis.x > 0:
		velocity.x -= draggable_speed / draggable.weight
	elif Input.is_action_pressed("ui_right") and draggable.current_axis.x > 0:
		velocity.x += draggable_speed / draggable.weight
	
	velocity.y += get_local_gravity() * 5
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


func _on_coyote_timer_timeout() -> void:
	_can_jump = false


func _on_flush_jump_buffer_timer_timeout() -> void:
	_jump_buffer = false


func fall_in_water() -> void:
	global_position = last_grounded_position


# Currently godot can't toggle visibility of 3D collision shapes at runtime, this is a workaround.
# See https://github.com/godotengine/godot-proposals/issues/2072
func _toggle_3d_collision_shape_visibility() -> void:
	var tree: SceneTree = get_tree()
	# https://github.com/godotengine/godot-proposals/issues/2072
	tree.debug_collisions_hint = not tree.debug_collisions_hint

	# Traverse tree to call toggle collision visibility
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is RayCast3D \
				or node is CollisionShape3D \
				or node is CollisionPolygon3D \
				#or node is CollisionObject3D \
				or node is GPUParticlesCollision3D \
				or node is GPUParticlesCollisionBox3D \
				or node is GPUParticlesCollisionHeightField3D \
				or node is GPUParticlesCollisionSDF3D \
				or node is GPUParticlesCollisionSphere3D:
				# remove and re-add the node to the tree to force a redraw
				# https://github.com/godotengine/godot/blob/26b1fd0d842fa3c2f090ead47e8ea7cd2d6515e1/scene/3d/collision_object_3d.cpp#L39
				var parent: Node = node.get_parent()
				if parent:
					parent.remove_child(node)
					parent.add_child(node)
			node_stack.append_array(node.get_children())
