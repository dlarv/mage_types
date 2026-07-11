@tool
extends Chunk

const CLAY_SHADER := preload("res://assets/shaders/clay_shader/clay_simple.gdshader")
const SolverMode := preload("res://world/subareas/maintenance_halls/MaintenanceSequence.gd").SolverMode
const INDICATOR_HEIGHT := 1.0
const INDICATOR_OFFSET := 1.5


@onready var model := $Chunk/maintenance_room/Backroom
var indicator_pos: Vector3
var model_width_x: float 
var model_width_z: float 

func _ready() -> void:
	model_width_x = model.get_aabb().size.x / 2.0
	model_width_z = model.get_aabb().size.z / 2.0
	# Account for door, which is 1 unit long.
	indicator_pos = Vector3(
		model_width_x - INDICATOR_OFFSET, 
		INDICATOR_HEIGHT / 2.0, 
		model_width_z - INDICATOR_OFFSET
	)

	if Engine.is_editor_hint(): return
	super._ready()


func set_color(element: ElementalType) -> void:
	# Set room's color
	var mat := ShaderMaterial.new()
	mat.shader = CLAY_SHADER
	mat.set_shader_parameter("base_color", element.main_color)
	model.set_surface_override_material(0, mat)


func add_indicators(otherElement: ElementalType, doorPos: int) -> void:
	# Point directly infront of doorway.
	var centerPoint: Vector3
	var offset: Vector3

	match doorPos:
		0: # RIGHT
			centerPoint = Vector3(indicator_pos.x, indicator_pos.y, 0)
			offset = Vector3.BACK
		1: # UP 
			centerPoint = Vector3(0, indicator_pos.y, indicator_pos.z)
			offset = Vector3.RIGHT
		2: # LEFT 
			centerPoint = Vector3(-indicator_pos.x, indicator_pos.y, 0)
			offset = Vector3.BACK
		3: # DOWN
			centerPoint = Vector3(0, indicator_pos.y, -indicator_pos.z)
			offset = Vector3.RIGHT

	var mat := StandardMaterial3D.new()
	mat.albedo_color = otherElement.main_color
	
	var box1 := MeshInstance3D.new()
	box1.mesh = BoxMesh.new()
	box1.mesh.size = Vector3(INDICATOR_HEIGHT, INDICATOR_HEIGHT, INDICATOR_HEIGHT)
	box1.position = centerPoint + offset * 2
	box1.set_surface_override_material(0, mat)
	box1.tree_entered.connect(func() -> void:
		box1.owner = get_tree().edited_scene_root)

	var box2 := MeshInstance3D.new()
	box2.mesh = BoxMesh.new()
	box2.mesh.size = Vector3(INDICATOR_HEIGHT, INDICATOR_HEIGHT, INDICATOR_HEIGHT)
	box2.position = centerPoint - offset * 2
	box2.set_surface_override_material(0, mat)
	box2.tree_entered.connect(func() -> void:
		box2.owner = get_tree().edited_scene_root)

	chunk.add_child(box1, true, INTERNAL_MODE_DISABLED)
	chunk.add_child(box2, true, INTERNAL_MODE_DISABLED)


func get_door_global_position(index: int, offset:=0.5) -> Vector3:
	var doorX := model_width_x + offset
	var doorZ := model_width_z + offset
	match index:
		0: # RIGHT
			return Vector3(doorX, 0, 0) + global_position
		1: # UP 
			return Vector3(0, 0, doorZ) + global_position
		2: # LEFT 
			return Vector3(-doorX, 0, 0) + global_position
		3: # DOWN
			return Vector3(0, 0, -doorZ) + global_position
	return Vector3.ZERO
