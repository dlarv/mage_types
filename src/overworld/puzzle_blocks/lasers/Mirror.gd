@tool
extends PuzzleBlock

## How long to continue emitting lasers w/o receiving a new impact.
@export var impact_delay := 1.0
## How long to wait between emitting projectiles.
@export var emit_delay := 0.5

var _prev_val := -1
var _time_since_last_emit := 0.0
var _time_since_last_impact := 0.0

var _body: Node3D
var _dir: Vector3
var _marker: Marker3D
var _e: ElementalType
var _y_pos: float

func _physics_process(delta: float) -> void:
	_time_since_last_emit += delta
	_time_since_last_impact += delta

	if _body == null: return
	if _time_since_last_impact <= impact_delay and _time_since_last_emit > emit_delay:
		emit_projectile(_body, _dir, _marker, _e)
		_time_since_last_emit = 0

func _on_rotated(obj:Node3D, player:Node3D) -> void:
	rotation_degrees.y += 90

func _on_area_3d_x_body_entered(body:Node3D) -> void:
	_on_body_entered(body, global_transform.basis.z, $Marker3DZ)

func _on_area_3d_z_body_entered(body:Node3D) -> void:
	_on_body_entered(body, -global_transform.basis.x, $Marker3DX)

func _on_body_entered(body: Node3D, direction: Vector3, marker: Node3D) -> void:
	if not body.get_collision_layer_value(5): return
	_time_since_last_impact = 0
	
	var e := ElementManager.get_matchup(element, body.element)

	if body.rand_val != _prev_val: 
		_prev_val = body.rand_val
		create_log(self, e)

	if in_stasis or e == null or e.is_blank():
		e = body.element
	
	_body = body.duplicate()
	_dir = direction
	_marker = marker
	_e = e
	_y_pos = body.global_position.y
	emit_projectile(body, direction, marker, e)


func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element.name])
	elif e == null or e.is_blank():
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element.name, body.element.name])
	else:
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element.name, body.element.name, e.name])


func emit_projectile(body: Node3D, direction: Vector3, marker: Node3D, e: ElementalType) -> void:
	_time_since_last_emit = 0.0

	var laser := body.duplicate()
	body.linear_velocity = Vector3.ZERO
	laser.setup(marker.position, direction, e, _prev_val)
	add_child(laser)
	laser.global_position.y = _y_pos
