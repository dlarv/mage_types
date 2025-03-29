@tool
extends PuzzleBlock

@export var horizontal := false
@export var size := 5.0:
	set(val):
		size = val
		_set_spout_size(size * _size_mod)

@export var base_strength := 15.0:
	set(val):
		base_strength = val
		# dot ~= 1, when geyser is pointing upward.
		_mod = Vector3.UP.dot(transform.basis.y)

var _size_mod: float:
	get:
		match element:
			ElementManager.Blue, ElementManager.Magenta: 
				return 0.5
			ElementManager.Purple: 
				return 0.8
			ElementManager.Orange:
				return 1.5
			ElementManager.Green:
				return 2.0
			ElementManager.Red,ElementManager.Yellow,ElementManager.Cyan,_: 
				return 1.0
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
	super._enter_tree()
	body_hitbox.shape = BoxShape3D.new()
	body_hitbox.shape.size = Vector3(1, size, 1)
	top_hitbox.shape = BoxShape3D.new()
	top_hitbox.shape.size = Vector3(1, 1, 1)
	$PlayerBlocker.get_node("CollisionShape3D").shape = $PlayerBlocker.get_node("CollisionShape3D").shape.duplicate()

func _ready() -> void:
	super._ready()
	if is_blocking:
		_set_blocking(true)
	else:
		_set_blocking(false)
	_set_spout_size(size * _size_mod)


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

func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if not super.set_element(e, randVal, force): return false

	if is_blocking:
		_set_blocking(true)
	else:
		_set_blocking(false)
	
	_animate_spout_size(size * _size_mod)

	return true


# Override
func set_stasis(val=null) -> void:
	super.set_stasis(val)
	if in_stasis:
		$AnimationPlayer.play("pausing")
		_set_blocking(false)
	else:
		$AnimationPlayer.play("starting")
		start()

#Override
func stop(val: Variant=null) -> void:
	if in_stasis: return
	super.stop()
	$AnimationPlayer.play("pausing")
	_set_blocking(false)

#Override
func start(val: Variant=null) -> void:
	if in_stasis: return
	super.start()
	$AnimationPlayer.play("starting")
	if is_blocking:
		await get_tree().create_timer(0.1).timeout
		_set_blocking(true)
	else:
		_set_blocking(false)

func _set_blocking(val: bool) -> void:
	$PlayerBlocker.set_collision_layer_value(6, val)

func _set_spout_size(val: float) -> void:
	top_hitbox.position.y = val
	body_hitbox.position.y = val / 2
	body_hitbox.shape.size.y = val

	if horizontal:
		print(puzzle_name)
		$PlayerBlocker.get_node("CollisionShape3D").shape.size.y = val
		$PlayerBlocker.get_node("CollisionShape3D").position.y = val / 2

func _animate_spout_size(val: float) -> void:
	top_hitbox.position.y = val
	body_hitbox.position.y = val / 2
	body_hitbox.shape.size.y = val

	if horizontal:
		print(puzzle_name)
		$PlayerBlocker.get_node("CollisionShape3D").shape.size.y = val
		$PlayerBlocker.get_node("CollisionShape3D").position.y = val / 2

