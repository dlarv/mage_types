@tool
extends CollisionObject3D
class_name MagiClay

signal stasis_ended()

@export_category("Elemental Traits")
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)

var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
		if Engine.is_editor_hint():
			_material = StandardMaterial3D.new()
@export var is_blooming: bool
@export var is_breakable: bool
@export var is_transmutable: bool
@export var in_stasis: bool
@export var tunnel_override: MagiClay

@export_category("Sizing")
@export var scaling_factor := Vector3(1, 1, 1):
	set(val):
		scaling_factor = val
		$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate(true)
		$CollisionShape3D.shape = $CollisionShape3D.shape.duplicate(true)
		_set_size()

@export var base_size := Vector3(1, 1, 1)

var puzzle_name: String
var _mesh_instance: MeshInstance3D: get = _get_mesh
var _material: StandardMaterial3D:
	set(val):
		_material = val
		if _mesh_instance == null:
			push_warning("%s has no mesh!" % puzzle_name)
			return
		_mesh_instance.set_surface_override_material(0, _material)
		_try_set_color()
var _original_element: ElementalType = null

# When this object is hit by a laser, this value is checked against the projectile's value.
# Every laser projectile in a beam has the same value and it is rerolled when the laser stops and starts again.
# This will prevent the object from strobing when hit by a laser.
var _rand_val: int

func _enter_tree():
	if _original_element == null:
		_original_element = element
	_flicker_collider()


func _ready():
	_material = StandardMaterial3D.new()
	puzzle_name = "%s.%s" % [get_parent().name, name]

# color: Color | null
func _try_set_color(color=null) -> void:
	if not _mesh_instance: return
	if not _material: return
	if not element: return
	if color == null:
		_material.albedo_color = element.main_color
	else:
		_material.albedo_color = color

func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if e == null or e.is_blank(): return false
	if in_stasis and not force:
		Logger.append_puzzle_log("MagiClay(%s).set_element(%s) failed, b/c Clay is in stasis." % [puzzle_name, e.name])
		return false
	elif not is_transmutable and not force: 
		Logger.append_puzzle_log("MagiClay(%s).set_element(%s) failed, b/c Clay is in not transmutable." % [puzzle_name, e.name])
		return false
	elif randVal != -2 and _rand_val == randVal and not force: 
		return false
	else:
		_rand_val = randVal
	element = e
	_try_set_color()
	Logger.append_puzzle_log("MagiClay(%s).set_element(%s) succeeded." % [puzzle_name, e.name])

	# The Catalyst overworld spell does not provide a randVal, so this can be used to test if this transmutation
	# was because of a laser or Catalyst.
	if randVal == -2:
		_flicker_collider()
	return true


func react(e: ElementalType, randVal:=-2) -> bool:
	var res := ElementManager.get_matchup(element, e)
	return set_element(res, randVal)

	
func set_stasis(val=null) -> void:
	if val == null:
		in_stasis = not in_stasis
	else:
		in_stasis = val

	if in_stasis:
		set_element(_original_element, -2, true)
		_try_set_color(Color.BLACK)
		Logger.append_puzzle_log("MagiClay(%s).set_stasis() => Clay is now in stasis." % [puzzle_name])
	else:
		_try_set_color()
		Logger.append_puzzle_log("MagiClay(%s).set_stasis() => Clay is no longer in stasis." % [puzzle_name])
		stasis_ended.emit()
	_flicker_collider()

func reset() -> void:
	Logger.append_puzzle_puzzle_log("%s reverted to original element. Element(%s) --> Element(%s)." 
			% [puzzle_name, element.name, _original_element.name])
	set_stasis(false)
	set_element(_original_element, _rand_val, true)

func bloom(val: bool, e: ElementalType) -> void:
	if not is_blooming: return

func destroy() -> void:
	if not is_breakable: return
	queue_free()

func try_tunnel() -> void:
	if tunnel_override == null: return

func _get_mesh() -> MeshInstance3D:
	if find_child("MeshInstance3D") == null: return null
	return $MeshInstance3D

func _flicker_collider() -> void:
	# Use case example:
	# 1. Object is Blue and is sitting on a Purple pressure plate.
	# 2. Object is transmuted into Purple.
	# 3. Collider is flickered, which re-triggers pressure plate.
	var val := collision_layer
	set_collision_layer_value(3, false)
	await get_tree().create_timer(0.01).timeout
	set_collision_layer_value(3, true)

func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"name": name,
		"position": global_position,
		"rotation": global_rotation,
		"scale": scale,
		"element": element.name,
		"in_stasis": in_stasis,
		"visible": visible,
	}

func deserialize(data: Dictionary) -> void:
	if "position" in data:
		global_position = data["position"]
	if "rotation" in data:
		global_rotation = data["rotation"]
	if "scale" in data:
		scale = data["scale"]
	if "element" in data:
		element = ElementManager.get_element_from_name(data["element"])
	if "in_stasis" in data:
		in_stasis = not data["in_stasis"]
		set_stasis()
	if "visible" in data:
		visible = data["visible"]

func _set_size() -> void:
	var mesh = $MeshInstance3D.mesh
	var shape = $CollisionShape3D.shape

	if shape is CylinderMesh:
		mesh.top_radius = base_size.x * scaling_factor.x
		mesh.bottom_radius = base_size.x * scaling_factor.x
		mesh.height = base_size.z * scaling_factor.z
	elif mesh is PlaneMesh:
		mesh.size.x = base_size.x * scaling_factor.x
		mesh.size.y = base_size.z * scaling_factor.z
	else:
		mesh.size = base_size * scaling_factor

	if shape is CylinderShape3D:
		shape.radius = base_size.x * scaling_factor.x
		shape.height = base_size.z * scaling_factor.z
	else:
		shape.size = base_size * scaling_factor
