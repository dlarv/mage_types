extends Node3D
class_name OverworldSpell

enum Spells { STASIS, DESTROY, CATALYST, VINES, TUNNEL }

@export var icon: Image
var Projectile: PackedScene

var is_active := false
var keycode: String

var _magiclay_terrain: MagiClay

func _input(event: InputEvent) -> void:
	if not is_active: return

	if event.is_action_pressed(keycode):
		_perform_action()

func _physics_process(delta: float) -> void:
	_magiclay_terrain = null
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3(0, 10, 0), 4)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	if result.get("collider") == null: return

	var clay = result["collider"]
	if clay is MagiClay:
		_magiclay_terrain = clay


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
	var forward: Vector3 = global_basis.z
	projectile.setup(collision_test, action_to_perform, element, forward)
	get_tree().get_root().add_child(projectile)
	projectile.global_position = global_position
