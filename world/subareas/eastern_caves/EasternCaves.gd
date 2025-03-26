extends Chunk

const Room := preload("room_templates/EasternCaveRoom.gd")
const RoomPortal := preload("res://addons/room_and_portals/RoomPortal.gd")

@export var templates: Array[PackedScene]
@export var room_count := 8
@export var correct_marker: Marker3D
@export var start_portal: RoomPortal
## How much vertical distance to put between each room instance.
@export var room_offset := -10.0

var _offensive_elements := []
var _o_index := 0
var _defensive_elements := []
var _d_index := 0

func _ready() -> void:
	_offensive_elements = [
		ElementManager.Purple,
		ElementManager.Red,
		ElementManager.Orange,
		ElementManager.Green,
	]
	_offensive_elements.shuffle()
	_o_index = 0

	_defensive_elements = [
		ElementManager.Blue,
		ElementManager.Magenta,
		ElementManager.Yellow,
		ElementManager.Cyan,
	]
	_defensive_elements.shuffle()
	_d_index = 0

	var rooms := []
	rooms.resize(room_count)
	rooms.fill(preload("room_templates/small_square.tscn"))
	_setup_rooms(rooms)

	
func _setup_rooms(rooms: Array) -> void:
	$CollisionShape3D.shape.size = Vector3(40, abs(room_offset * room_count), 40)
	$CollisionShape3D.position.y = room_offset * room_count / 2

	var yOffset := 0.0
	var prevDirection := Room.Direction.E
	var currElement := ElementManager.Blue
	var prevElement := ElementManager.Blank
	var prevRoom: Room = null
	var isDefensive := false

	var i := 0
	for room in rooms:
		room = room.instantiate()
		$Chunk.add_child(room)

		# Connect start portal to beginning of cave system.
		if i == 0:
			var portal = room.get_portal(Room.Direction.W)
			start_portal.point_2 = portal.point_1
			currElement = _defensive_elements[_d_index]
			_d_index += 1
		i += 1

		# Position room.
		room.global_position.y = yOffset
		yOffset += room_offset

		var data := _setup_room(room, currElement, prevElement, prevDirection, isDefensive)

		# Shift current room to previous.
		if prevRoom:
			prevRoom.connect_correct_portal(room, prevDirection)
		prevRoom = room

		prevDirection = data[0]
		prevElement = currElement
		currElement = data[1]
		isDefensive = not isDefensive

	prevRoom.get_portal(prevDirection).point_2 = correct_marker


func _setup_room(instance: Room, currElement: ElementalType, prevElement: ElementalType, prevDir: Room.Direction, isDefensive: bool) -> Array:
	var nextElement: ElementalType
	var otherElements: Array

	# Determine what colors the neighbors will be.
	if _d_index == 4 and _o_index == 4:
		nextElement = ElementManager.Blank
		otherElements = _offensive_elements
	elif isDefensive:
		nextElement = _defensive_elements[_d_index]
		_d_index += 1
		otherElements = _offensive_elements
	else:
		nextElement = _offensive_elements[_o_index]
		_o_index += 1
		otherElements = _defensive_elements

	# Get colors of incorrect rooms, ensuring there are no duplicates
	var nextRooms := []
	while len(nextRooms) < 3:
		var e: ElementalType = otherElements.pick_random()
		if not e in nextRooms and e != currElement:
			nextRooms.append(e)
	
	return [
		instance.setup(nextElement, currElement, prevElement, prevDir, nextRooms, start_portal.point_1),
		nextElement ]
