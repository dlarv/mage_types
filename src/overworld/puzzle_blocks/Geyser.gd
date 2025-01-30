@tool
extends PuzzleBlock

@export var size := 5.0:
	set(val):
		size = val
		top_hitbox.position.y = size
		body_hitbox.position.y = size / 2
		body_hitbox.shape.size.y = size
		_set_keyframes()

@export var base_strength := 15.0:
	set(val):
		base_strength = val
		# dot ~= 1, when geyser is pointing upward.
		_mod = Vector3.UP.dot(transform.basis.y)
	
var _mod := 1.0
var strength: float:
	get:
		return base_strength - 10.0 * _mod

var top_hitbox: CollisionShape3D:
	get:
		return get_node("StreamTopHitBox/CollisionShape3D")
var body_hitbox: CollisionShape3D:
	get:
		return get_node("StreamBodyHitBox/CollisionShape3D")

var is_blocking: bool:
	get:
		return element != ElementManager.Yellow

var _player: Node3D

func _enter_tree():
	body_hitbox.shape = BoxShape3D.new()
	body_hitbox.shape.size = Vector3(1, size, 1)
	top_hitbox.shape = BoxShape3D.new()
	top_hitbox.shape.size = Vector3(1, 1, 1)

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	if _player != null:
		_player.outside_forces += transform.basis.y * strength * delta

func _on_stream_hit_box_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		# If body is falling back down from the height of the geyser, slow it down faster.
		if body.linear_velocity.y < 0:
			body.linear_velocity /= 2
		body.add_constant_force(transform.basis.y * strength)
	elif body is CharacterBody3D:
		if is_blocking:
			body.outside_forces = -body.velocity * 3
		else:
			body.outside_forces += transform.basis.y * strength
			_player = body

	
func _on_stream_top_hit_box_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		# If body is falling back down from the height of the geyser, slow it down faster.
		if body.linear_velocity.y < 0:
			body.linear_velocity /= 2
		body.add_constant_force(transform.basis.y * strength)
	elif body is CharacterBody3D:
		body.outside_forces += transform.basis.y * strength


func _on_stream_hit_box_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.constant_force = Vector3.ZERO
	elif body is CharacterBody3D:
		_player = null

# Override
func set_stasis(val: bool, timeLength:=0.5) -> void:
	$AnimationPlayer.play("pausing")
	await super.set_stasis(val, timeLength)
	if not in_stasis:
		$AnimationPlayer.play("starting")

func _set_keyframes() -> void:
	var val := Vector3(0, size, 0)
	var pausing: Animation = $AnimationPlayer.get_animation("pausing")
	pausing.track_set_key_value(0, 0, val / 2)
	pausing.track_set_key_value(0, 1, -val / 2)
	pausing.track_set_key_value(1, 0, val)
	# pausing.track_set_key_value(1, 1, -size / 2)

	var starting: Animation = $AnimationPlayer.get_animation("starting")
	starting.track_set_key_value(0, 1, val)
	starting.track_set_key_value(1, 0, -val / 2)
	starting.track_set_key_value(1, 1, val / 2)

#Override
func stop(val: Variant=null) -> void:
	super.stop()
	$AnimationPlayer.play("pausing")

#Override
func start(val: Variant=null) -> void:
	if in_stasis:
		await self.stasis_ended
	super.start()
	$AnimationPlayer.play("starting")
