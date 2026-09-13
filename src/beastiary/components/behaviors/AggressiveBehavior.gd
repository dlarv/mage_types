@tool
extends _EnemyBehavior

var _is_hunting := false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	super._ready()
	if ProjectSettings.get_setting("custom/general/debug_mode"):
		var indicator := MeshInstance3D.new()
		indicator.name = "TargetIndicator"
		indicator.mesh = SphereMesh.new()
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.RED
		indicator.mesh.surface_set_material(0, mat)
		indicator.top_level = true
		add_child(indicator, true)

# override
## Logic to determine enemy's next action should go in here.
func _on_timer_timeout() -> void: 
	var pos: Vector3
	_is_hunting = _player != null

	if not _is_hunting:
		pos = Vector3(
			global_position.x + randf_range(-10, 10),
			global_position.y,
			global_position.z + randf_range(-10, 10)
		)
	else:
		pos = _player.global_position
	
	pos.y = global_position.y
	navigation_agent.set_target_position(pos)

	
#override
func get_next_position() -> Vector3: 
	if not navigation_agent.is_target_reachable(): return Vector3.ZERO
	var pos := navigation_agent.get_next_path_position()
	return global_position.direction_to(pos) * base_speed


#override
func get_next_animation() -> String: return ""


#override
func _on_body_entered(node: Node3D) -> void:
	super._on_body_entered(node)
	_on_timer_timeout()
