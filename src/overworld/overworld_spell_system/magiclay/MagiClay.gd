@tool
extends CollisionObject3D
class_name MagiClay

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

var _mesh: MeshInstance3D:
	get:
		return $MeshInstance3D
var _material: StandardMaterial3D:
	set(val):
		_material = val
		_mesh.set_surface_override_material(0, _material)
		_try_set_color()

func _ready():
	_material = StandardMaterial3D.new()


func _try_set_color() -> void:
	if _mesh == null: return
	if element == null: return
	_material.albedo_color = element.main_color

func set_element(e: ElementalType) -> void:
	if in_stasis: return
	if not is_transmutable: return
	if e == null or e.is_blank(): return
	element = e
	_try_set_color()
	
func set_stasis(val: bool, timeLength:=0.5) -> void:
	if in_stasis: return
	in_stasis = true
	var prevColor := _material.albedo_color
	_material.albedo_color = Color.BLACK
	await get_tree().create_timer(timeLength).timeout
	_material.albedo_color = prevColor
	in_stasis = false


func bloom(val: bool, e: ElementalType) -> void:
	if not is_blooming: return

func destroy() -> void:
	if not is_breakable: return
	queue_free()

func try_tunnel() -> void:
	if tunnel_override == null: return
