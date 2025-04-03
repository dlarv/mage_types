extends Node3D
class_name OverworldSpell

enum Spells { STASIS, DESTROY, CATALYST, VINES, TUNNEL, NONE }

@export var icon: CompressedTexture2D
var Projectile: PackedScene

var is_active := false

var _terrain_exclusions: Array

var _magiclay_terrain: MagiClay
var _current_mouse_pos: Vector3

func _ready() -> void:
	_terrain_exclusions = get_tree().get_nodes_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_active: return
	_get_magiclay()
	_find_mouse_position()

func _get_magiclay() -> void:
	_magiclay_terrain = null
	var space := get_world_3d().direct_space_state
	var start := global_position
	start.y += 2
	var query := PhysicsRayQueryParameters3D.create(start, global_position - Vector3(0, 10, 0), 4)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	if result.get("collider") == null: return

	var clay = result["collider"]
	if clay is MagiClay:
		_magiclay_terrain = clay

func _find_mouse_position() -> void:
	var cam := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()

	var origin := cam.project_ray_origin(mousePos)
	var end := origin + cam.project_ray_normal(mousePos) * 1000
	var query := PhysicsRayQueryParameters3D.create(origin, end, 2)
	var pos = get_world_3d().direct_space_state.intersect_ray(query).get("position")

	if pos != null:
		_current_mouse_pos = pos - global_position
		_current_mouse_pos.y = position.y
	else:
		_current_mouse_pos = position

func deactivate() -> void:
	is_active = false

func set_primary(val: bool) -> void:
	is_active = true

# Virtual
func perform_action() -> void: pass

func _channel_element() -> ElementalType: 
	if _magiclay_terrain != null:
		return _magiclay_terrain.element
	return ElementManager.Blank

func _spawn_projectile(collision_test: Callable, action_to_perform: Callable, element: ElementalType) -> void:
	var projectile := Projectile.instantiate()
	var target: Vector3
	if not Settings.use_mouse_targeting:
		target = global_basis.z
	else:
		target = _current_mouse_pos.normalized()

	projectile.setup(collision_test, action_to_perform, element, target)
	get_tree().get_root().add_child(projectile)
	projectile.global_position = global_position
