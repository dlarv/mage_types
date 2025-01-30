extends Node3D
class_name OverworldSpell

enum Spells { STASIS, DESTROY, CATALYST, VINES, TUNNEL }

@export var icon: Image
var Projectile: PackedScene

var is_active := false
var keycode: String

var _magiclay_terrain: MagiClay
var _current_mouse_pos: Vector3

func _input(event: InputEvent) -> void:
	if not is_active: return

	if event.is_action_pressed(keycode):
		_perform_action()

func _physics_process(delta: float) -> void:
	if not is_active: return
	_get_magiclay()
	_find_mouse_position()

func _get_magiclay() -> void:
	_magiclay_terrain = null
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3(0, 10, 0), 4)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	if result.get("collider") == null: return

	var clay = result["collider"]
	if clay is MagiClay:
		_magiclay_terrain = clay

func _find_mouse_position() -> void:
	# if not Settings.use_mouse_targeting: return
	var cam = get_viewport().get_camera_3d()
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
	keycode = ""

func set_primary(val: bool) -> void:
	is_active = true
	if val:
		keycode = "cast_spell_1"
	else:
		keycode = "cast_spell_2"

# Virtual
func _perform_action() -> void: pass

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
	print(target)

	projectile.setup(collision_test, action_to_perform, element, target)
	get_tree().get_root().add_child(projectile)
	projectile.global_position = global_position

