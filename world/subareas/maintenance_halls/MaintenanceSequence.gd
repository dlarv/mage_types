@tool
extends Node3D
## Handle instantiation of maintenance hallway

const ElementalEnum := ElementalType.ElementalEnum
const MODEL := preload("res://world/subareas/maintenance_halls/maintenance_room.tscn")
const CLAY_SHADER := preload("res://assets/3d/shaders/clay_shader/clay.tres")
const RoomPortal := preload("res://addons/room_and_portals/RoomPortal.gd")

enum SolverMode { AFFINITY, TEMP }

@export var start_point: Marker3D
@export var solver_mode := SolverMode.AFFINITY
@export var room_offset := 20.0
@export_enum("RIGHT", "UP", "LEFT", "DOWN")
var exit_room_direction := 0
@export_enum("RIGHT", "UP", "LEFT", "DOWN")
var start_room_direction := 3
@export var sequence: Array[ElementalEnum]

@export_tool_button("Generate")
var generate_action: Callable = _generate
@export_tool_button("Clear")
var clear_action: Callable = _clear

var offset := Vector3.ZERO

func _generate() -> void:
	_clear()
	var initialGlobalPosition := global_position
	global_position = Vector3.ZERO
	
	if not start_point:
		start_point = Marker3D.new()
		add_child(start_point, true)
		start_point.owner = get_tree().edited_scene_root
		start_point.position.z = -15

	## Right, Up, Left, Down
	var correctDoorDir := start_room_direction
	var prevDoor: Marker3D = null
	var prevRoom: Node3D = null
	offset = Vector3.ZERO
	var portalSize := Vector3(1, 7, 3)

	var i := -1
	for id in sequence:
		i += 1
		var element := ElementManager.get_element_from_enum(id)

		var room := create_room(i, element) 

		# Connect previous correct door
		var doorDirs := range(4)
		if prevDoor:
			var prevDoorDir := -1
			prevDoorDir = (correctDoorDir + 2) % 4
			prevDoor.global_position = room.get_door_global_position(prevDoorDir, -0.5)
			prevDoor.position.y = 3.5
		prevRoom = room
		prevDoor = Marker3D.new()
		add_child(prevDoor)

		# Select next correct door direction.
		if i == len(sequence) - 1:
			correctDoorDir = exit_room_direction
		else:
			correctDoorDir = doorDirs.pick_random()
		doorDirs.remove_at(doorDirs.find(correctDoorDir))

		# Defined up here so that correct answer cannot be selected twice.
		var incorrectColors := get_incorrect_colors(element)

		# Exit should be handled manually.
		# Otherwise, create doorway to correct room.
		if i < len(sequence) - 1:
			var portal := create_portal(room.get_door_global_position(correctDoorDir), prevDoor, true)
			rotate_door(portal, correctDoorDir)
			portal.name = "%dTo%d" % [i, i + 1]

			var color: ElementalType = ElementManager.get_element_from_enum(sequence[i + 1])
			incorrectColors.remove_at(incorrectColors.find(color))
			room.add_indicators(color, correctDoorDir)

		# Connect incorrect doors to beginning.
		for door: int in doorDirs:
			var portal := create_portal(room.get_door_global_position(door), start_point) 

			portal.name = "Room%dToSTART" % i
			rotate_door(portal, door)

			var color: ElementalType = incorrectColors.pop_at(randi_range(0, len(incorrectColors) - 1))
			room.add_indicators(color, door)

	global_position = initialGlobalPosition


func _clear() -> void:
	for child in $Chunks.get_children(true):
		$Chunks.remove_child(child)

	for child in $Doors.get_children(true):
		$Doors.remove_child(child)


func get_incorrect_colors(element: ElementalType) -> Array:
	var COLD := [ElementManager.Blue, ElementManager.Purple, ElementManager.Green, ElementManager.Cyan]
	var WARM := [ElementManager.Red, ElementManager.Orange, ElementManager.Yellow, ElementManager.Magenta]
	var OFF := [ElementManager.Purple, ElementManager.Red, ElementManager.Orange, ElementManager.Green]
	var DEF := [ElementManager.Blue, ElementManager.Magenta, ElementManager.Yellow, ElementManager.Cyan]
	var output := []

	match solver_mode:
		SolverMode.AFFINITY:
			if element in OFF:
				output = OFF
			else:
				output = DEF
		SolverMode.TEMP:
			if element in COLD:
				output = COLD
			else:
				output = WARM
	output.remove_at(output.find(element))
	return output


func rotate_door(door: RoomPortal, dir: int) -> void:
	var child1 := door.get_child(0)
	var child2 := Node3D.new()
	if door.get_child_count() > 1:
		child2 = door.get_child(1)

	match dir:
		0:
			child1.rotation_degrees.y = 180
		1:
			child1.rotation_degrees.y = 90
			child2.rotation_degrees.y = -90
		2:
			child2.rotation_degrees.y = 180
		3:
			child1.rotation_degrees.y = -90
			child2.rotation_degrees.y = 90


func create_room(i: int, element: ElementalType) -> Node3D:
	var room := MODEL.instantiate()
	room.name = "Room%d" % (i + 1)
	$Chunks.add_child(room, true, INTERNAL_MODE_DISABLED)
	room.owner = get_tree().edited_scene_root
	set_editable_instance(room, true)

	room.set_color(element)

	room.position = offset
	if i % 4 == 3:
		offset.z += room_offset
		offset.x = 0
	else:
		offset.x += room_offset
	return room


func create_portal(pos: Vector3, marker: Marker3D, reparent:=false) -> RoomPortal:
	var portalSize := Vector3(1, 7, 3)
	var portal := RoomPortal.create_half_door(
			pos, 
			marker, 
			portalSize
	)
	$Doors.add_child(portal, true, INTERNAL_MODE_DISABLED)
	portal.owner = get_tree().edited_scene_root

	# Collider 1
	portal.get_child(0).owner = get_tree().edited_scene_root
	# Marker 1
	portal.get_child(0).get_child(0).owner = get_tree().edited_scene_root
	# Marker 2
	if reparent:
		marker.reparent(portal)
		marker.owner = get_tree().edited_scene_root
	return portal 
