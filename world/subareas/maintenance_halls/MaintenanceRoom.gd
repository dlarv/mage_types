@tool
extends Chunk

const CLAY_SHADER := preload("res://assets/3d/shaders/clay_shader/clay.tres")
const SolverMode := preload("res://world/subareas/maintenance_halls/MaintenanceSequence.gd").SolverMode

@onready var model := $Chunk/maintenance_room/Backroom

func _ready() -> void:
	if Engine.is_editor_hint(): return
	super._ready()


func set_color(element: ElementalType) -> void:
	# Set room's color
	var mat := ShaderMaterial.new()
	mat.shader = CLAY_SHADER
	mat.set_shader_parameter("BaseColor", element.main_color)
	model.set_surface_override_material(0, mat)


func add_indicators(otherElement: ElementalType, doorPos: int) -> void:
	# Point directly infront of doorway.
	var centerPoint: Vector3
	var offset: Vector3
	var boxHeight := 1.0

	match doorPos:
		0: # RIGHT
			# Account for door, which is 1 unit long.
			centerPoint = Vector3(model.scale.x - 1, boxHeight / 2.0, 0)
			offset = Vector3.BACK
		1: # UP 
			centerPoint = Vector3(0, boxHeight / 2.0, model.scale.z - 1)
			offset = Vector3.RIGHT
		2: # LEFT 
			centerPoint = Vector3(-model.scale.x + 1, boxHeight / 2.0, 0)
			offset = Vector3.BACK
		3: # DOWN
			centerPoint = Vector3(0, boxHeight / 2.0, -model.scale.z + 1)
			offset = Vector3.RIGHT

	var mat := StandardMaterial3D.new()
	mat.albedo_color = otherElement.main_color
	
	var box1 := MeshInstance3D.new()
	box1.mesh = BoxMesh.new()
	box1.mesh.size = Vector3(boxHeight, boxHeight, boxHeight)
	box1.position = centerPoint + offset * 2
	box1.set_surface_override_material(0, mat)
	box1.tree_entered.connect(func() -> void:
		box1.owner = get_tree().edited_scene_root)

	var box2 := MeshInstance3D.new()
	box2.mesh = BoxMesh.new()
	box2.mesh.size = Vector3(boxHeight, boxHeight, boxHeight)
	box2.position = centerPoint - offset * 2
	box2.set_surface_override_material(0, mat)
	box2.tree_entered.connect(func() -> void:
		box2.owner = get_tree().edited_scene_root)

	chunk.add_child(box1, true, INTERNAL_MODE_DISABLED)
	chunk.add_child(box2, true, INTERNAL_MODE_DISABLED)


func get_door_global_position(index: int, offset:=0.5) -> Vector3:
	match index:
		0: # RIGHT
			# Account for door, which is 1 unit long.
			return Vector3(model.scale.x + offset, 0, 0) + global_position
		1: # UP 
			return Vector3(0, 0, model.scale.z + offset) + global_position
		2: # LEFT 
			return Vector3(-model.scale.x - offset, 0, 0) + global_position
		3: # DOWN
			return Vector3(0, 0, -model.scale.z - offset) + global_position
	return Vector3.ZERO

