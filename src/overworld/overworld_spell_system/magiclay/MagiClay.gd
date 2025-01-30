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

var _mesh: MeshInstance3D: get = _get_mesh
var _material: StandardMaterial3D:
	set(val):
		_material = val
		if _mesh == null: return
		_mesh.set_surface_override_material(0, _material)
		_try_set_color()

# When this object is hit by a laser, this value is checked against the projectile's value.
# Every laser projectile in a beam has the same value and it is rerolled when the laser stops and starts again.
# This will prevent the object from strobing when hit by a laser.
var _rand_val: int

func _ready():
	_material = StandardMaterial3D.new()


func _try_set_color() -> void:
	if _mesh == null: return
	if element == null: return
	_material.albedo_color = element.main_color

func set_element(e: ElementalType, randVal:=-2) -> bool:
	if in_stasis: return false
	if not is_transmutable: return false
	if e == null or e.is_blank(): return false
	if _rand_val == randVal: return false
	_rand_val = randVal
	element = e
	_try_set_color()
	return true
	
func set_stasis(val: bool, timeLength:=0.5) -> void:
	if in_stasis: return
	in_stasis = true
	var prevColor := _material.albedo_color
	_material.albedo_color = Color.BLACK
	await get_tree().create_timer(timeLength).timeout
	stasis_ended.emit()
	_material.albedo_color = prevColor
	in_stasis = false


func bloom(val: bool, e: ElementalType) -> void:
	if not is_blooming: return

func destroy() -> void:
	if not is_breakable: return
	queue_free()

func try_tunnel() -> void:
	if tunnel_override == null: return

func _get_mesh() -> MeshInstance3D:
	return $MeshInstance3D
