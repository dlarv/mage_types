@tool
extends CollisionObject3D
class_name MagiClay

signal stasis_ended()

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

var puzzle_name: String:
	get:
		if get_parent() == null:
			return "%s" % name
		return "%s.%s" % [get_parent().name, name]
var _mesh: MeshInstance3D: get = _get_mesh
var _material: StandardMaterial3D:
	set(val):
		_material = val
		if _mesh == null: return
		_mesh.set_surface_override_material(0, _material)
		_try_set_color()
var _original_element: ElementalType

# When this object is hit by a laser, this value is checked against the projectile's value.
# Every laser projectile in a beam has the same value and it is rerolled when the laser stops and starts again.
# This will prevent the object from strobing when hit by a laser.
var _rand_val: int

func _enter_tree():
	_original_element = element


func _ready():
	_material = StandardMaterial3D.new()


func _try_set_color() -> void:
	if _mesh == null: return
	if element == null: return
	_material.albedo_color = element.main_color

func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if e == null or e.is_blank(): return false
	if in_stasis and not force:
		Logger.append_log(Logger.LogType.PUZZLE, 
				"MagiClay(%s).set_element(%s) failed, b/c Clay is in stasis." % [puzzle_name, e.name])
		return false
	elif not is_transmutable and not force: 
		Logger.append_log(Logger.LogType.PUZZLE, 
				"MagiClay(%s).set_element(%s) failed, b/c Clay is in not transmutable." % [puzzle_name, e.name])
		return false
	elif randVal != -2 and _rand_val == randVal and not force: 
		return false
	else:
		_rand_val = randVal
	element = e
	_try_set_color()
	Logger.append_log(Logger.LogType.PUZZLE, 
			"MagiClay(%s).set_element(%s) succeeded." % [puzzle_name, e.name])

	_flicker_collider()
	return true
	
func set_stasis() -> void:
	in_stasis = not in_stasis
	if in_stasis:
		_material.albedo_color = Color.BLACK
		Logger.append_log(Logger.LogType.PUZZLE, 
				"MagiClay(%s).set_stasis() => Clay is now in stasis." % [puzzle_name])

	else:
		_material.albedo_color = element.main_color
		Logger.append_log(Logger.LogType.PUZZLE, 
				"MagiClay(%s).set_stasis() => Clay is no longer in stasis." % [puzzle_name])
		stasis_ended.emit()
	_flicker_collider()

func reset() -> void:
	Logger.append_log(Logger.LogType.PUZZLE, "%s reverted to original element. Element(%s) --> Element(%s)." 
			% [puzzle_name, element.name, _original_element.name])
	in_stasis = false
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
	collision_layer = 1
	await get_tree().create_timer(0.01).timeout
	collision_layer = val
