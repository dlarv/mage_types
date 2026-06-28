@tool
extends CollisionObject3D
class_name MagiClay

signal stasis_ended()
signal element_changed(element: ElementalType)

enum MagiClayEffectMode { FANCY, SOLID, NONE }

@export_category("Elemental Traits")
@export var _element := ElementalType.ElementId.BLANK:
	set(value):
		_element = value
		set_element(ElementManager.elements[int(value)], -2, true)

var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
		element_changed.emit(value)
		_try_set_color()
	get:
		if Engine.is_editor_hint() or element != null:
			return element
		return ElementManager.Blank
@export var is_breakable: bool
@export var is_transmutable: bool
@export var in_stasis: bool

@onready var puzzle_name := "%s.%s" % [get_parent().name, name]
@onready var spawn_position := global_position

@export var _mesh_instance: MeshInstance3D
var _material: Material:
	get:
		if _mesh_instance == null: return null
		return _mesh_instance.get_active_material(0)
var _original_element: ElementalType = null

# When this object is hit by a laser, this value is checked against the projectile's value.
# Every laser projectile in a beam has the same value and it is rerolled when the laser stops and starts again.
# This will prevent the object from strobing when hit by a laser.
var _rand_val: int

func _enter_tree() -> void:
	if _original_element == null:
		_original_element = element
	flicker_collider()


func _ready() -> void:
	_try_set_color()


## color: Color | null
func _try_set_color(color:Variant=null) -> bool:
	if not _material: return false
	if not element: return false

	if _material.next_pass != null:
		_material.next_pass.set_shader_parameter("element_id", element.id)

	if _material is ShaderMaterial:
		_material.set_shader_parameter("element_id", element.id)
		return true

	if color == null:
		_material.albedo_color = element.main_color
	else:
		_material.albedo_color = color
	return true


func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if e == null: return false
	if in_stasis and not force:
		MyLogger.append_puzzle_log("MagiClay(%s).set_element(%s) failed, b/c Clay is in stasis." 
				% [puzzle_name, e.name])
		return false
	elif not is_transmutable and not force: 
		MyLogger.append_puzzle_log("MagiClay(%s).set_element(%s) failed, b/c Clay is in not transmutable." 
				% [puzzle_name, e.name])
		return false
	elif randVal != -2 and _rand_val == randVal and not force: 
		return false
	else:
		_rand_val = randVal
	element = e
	_try_set_color()
	MyLogger.append_puzzle_log("MagiClay(%s).set_element(%s) succeeded." % [puzzle_name, e.name])

	# The Catalyst overworld spell does not provide a randVal, so this can be used to test if this transmutation
	# was because of a laser or Catalyst.
	if randVal == -2:
		flicker_collider()
	return true


func react(e: ElementalType, randVal:=-2) -> bool:
	var res := ElementManager.get_matchup(element, e)
	@warning_ignore("redundant_await")
	return await set_element(res, randVal)

	
## val: bool | null
func set_stasis(val:Variant=null) -> void:
	if val == null:
		in_stasis = not in_stasis
	else:
		in_stasis = val

	if in_stasis:
		set_element(_original_element, -2, true)
		_try_set_color(Color.BLACK)
		MyLogger.append_puzzle_log("MagiClay(%s).set_stasis() => Clay is now in stasis." % [puzzle_name])
	else:
		_try_set_color()
		MyLogger.append_puzzle_log("MagiClay(%s).set_stasis() => Clay is no longer in stasis." % [puzzle_name])
		stasis_ended.emit()
	await flicker_collider()


func reset(resetPosition:=false) -> void:
	MyLogger.append_puzzle_log("%s reverted to original element. Element(%s) --> Element(%s)." 
			% [puzzle_name, element, _original_element])
	set_element(_original_element, _rand_val, true)
	set_stasis(false)

	if resetPosition:
		print("%s, %s" % [global_position, spawn_position])
		global_position = spawn_position


func destroy() -> void:
	if not is_breakable: return
	queue_free()


func serialize() -> Dictionary: return {
		"path": get_path(),
		"name": name,
		"position": global_position,
		"rotation": global_rotation,
		"scale": scale,
		"element": int(element.id),
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
		element = ElementManager.elements[data["element"]]
	if "in_stasis" in data:
		in_stasis = not data["in_stasis"]
		set_stasis()
	if "visible" in data:
		visible = data["visible"]


func flicker_collider() -> void:
	if Engine.is_editor_hint() or not is_inside_tree(): return
	# Use case example:
	# 1. Object is Blue and is sitting on a Purple pressure plate.
	# 2. Object is transmuted into Purple.
	# 3. Collider is flickered, which re-triggers pressure plate.
	var val := collision_layer
	set_collision_layer_value(3, false)
	await get_tree().create_timer(0.01).timeout
	set_collision_layer_value(3, true)


func fall_in_water() -> void:
	global_position = spawn_position


static func set_magiclay_effect_mode(mode: MagiClayEffectMode) -> void:
	RenderingServer.global_shader_parameter_set("magiclay_effect_mode", int(mode))
