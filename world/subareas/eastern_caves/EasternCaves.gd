extends Chunk

const Room := preload("room_templates/EasternCaveRoom.gd")

@export var templates: Array[PackedScene]
@export var room_count := 8
@export var incorrect_marker: Marker3D
@export var correct_marker: Marker3D
## How much vertical distance to put between each room instance. Rooms are stacked vertically from top to bottom.
@export var room_offset := 10.0

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
	var yOffset := -20.0
	var prevDirection := Room.Direction.E
	var currElement := ElementManager.Blank
	var prevElement := ElementManager.Blank
	var prevRoom: Room = null
	var isDefensive := true

	for room in rooms:
		room = room.instantiate()
		$Chunk.add_child(room)

		# Position room.
		room.global_position.y = yOffset
		yOffset -= room_offset

		var data := _setup_room(room, currElement, prevElement, prevDirection, isDefensive)
		prevDirection = data[0]
		prevElement = currElement
		currElement = data[1]
		isDefensive = not isDefensive

		if prevRoom:
			prevRoom.connect_correct_portal(room, prevDirection)
		prevRoom = room
	prevRoom.get_portal(prevDirection).point_2 = correct_marker


func _setup_room(instance: Room, currElement: ElementalType, prevElement: ElementalType, prevDir: Room.Direction, isDefensive: bool) -> Array:
	var nextElement: ElementalType
	var otherElements: Array

	# Determine what colors the neighbors will be.
	if isDefensive:
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
		instance.setup(nextElement, currElement, prevElement, prevDir, nextRooms, incorrect_marker),
		nextElement ]

