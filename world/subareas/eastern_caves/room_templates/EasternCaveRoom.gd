extends Node3D

enum Direction { N, E, S, W }

const DOOR_DECALS := {
	"Blue": preload("door_decals/blue.tscn"),
	"Purple": preload("door_decals/purple.tscn"),
	"Magenta": preload("door_decals/magenta.tscn"),
	"Red": preload("door_decals/red.tscn"),
	"Orange": preload("door_decals/orange.tscn"),
	"Yellow": preload("door_decals/yellow.tscn"),
	"Green": preload("door_decals/green.tscn"),
	"Cyan": preload("door_decals/cyan.tscn"),
}


var correct_door: Direction
var element: ElementalType
var doors := {}

@onready var _decor_parent: Node3D = $Decor
var _puzzle_parent: Node3D

func _ready() -> void:
	_puzzle_parent = $Puzzle
	_puzzle_parent.hide()

## Assign elements to physical door.
## Show the correct puzzle/decor.
## element: Element of this room.
## prev: Element of previous room.
## prevDir: Direction of previous correct door. Entrance should be placed opposite of this.
## fakes: Array containing incorrect options.
## fakeMarker: This is where the player should be sent if they choose the wrong door.
func setup(next: ElementalType, curr: ElementalType, prev: ElementalType, prevDir: Direction, fakes: Array, fakeMarker: Marker3D) -> Direction:
	var dirs := [ Direction.N, Direction.E, Direction.S, Direction.W ]
	dirs.shuffle()

	_set_room_element(curr)

	# Setup door to previous room.
	prevDir = _get_opposite_direction(prevDir)
	# _set_door_element(prev, prevDir)
	_mark_door_as_prev(prevDir)
	dirs.remove_at(dirs.find(prevDir))
	doors[prevDir] = curr 
	_connect_portal(prevDir, fakeMarker)

	# Setup correct door.
	correct_door = dirs.pop_back()
	_set_door_element(next, correct_door)
	doors[correct_door] = next

	# Setup incorrect doors.
	var i := 0
	while len(dirs) > 0:
		var door = dirs.pop_back()
		var e: ElementalType = fakes[i]
		i += 1
		doors[door] = e
		_set_door_element(e, door)
		_connect_portal(door, fakeMarker)

	return correct_door

func get_portal(dir: Direction) -> Node3D:
	match dir:
		Direction.N: return $RoomPortal_N
		Direction.E: return $RoomPortal_E
		Direction.S: return $RoomPortal_S
		Direction.W,_: return $RoomPortal_W
	
func connect_correct_portal(nextRoom: Node3D, dir: Direction) -> void:
	var portal := get_portal(correct_door)
	portal.point_2 = nextRoom.get_portal(_get_opposite_direction(dir)).point_1

func get_element_of(dir: Direction) -> ElementalType:
	return doors[dir]

func set_difficulty(level: int) -> void:
	if level <= 0: return
	match level:
		1, 2, 3: 
			level = 0
		_:
			level = 1

	_puzzle_parent.process_mode = Node.PROCESS_MODE_INHERIT
	_puzzle_parent.show()

	var puzzleName := element.name
	var puzzleNameAlt := "%s_%d" % [ puzzleName, level ]

	var puzzle = _puzzle_parent.find_child(puzzleName)
	if puzzle:
		puzzle.process_mode = PROCESS_MODE_INHERIT
		puzzle.show()
		return

	puzzle = _puzzle_parent.find_child(puzzleNameAlt)
	if puzzle:
		puzzle.process_mode = PROCESS_MODE_INHERIT
		puzzle.show()
	else:
		Logger.append_log(Logger.LogType.WORLD, "No Element(%s) puzzle found in %s." % [ element.name, name ])
		push_warning("No Element(%s) puzzle found in %s." % [ element.name, name ])


func _get_opposite_direction(dir: Direction) -> Direction:
	match dir:
		Direction.N: return Direction.S
		Direction.E: return Direction.W
		Direction.S: return Direction.N
		Direction.W,_: return Direction.E

func _set_room_element(element: ElementalType) -> void:
	self.element = element
	if element.is_blank(): return

	var decal = DOOR_DECALS[element.name].instantiate()
	add_child(decal)

	var decor = $Decor.find_child(element.name)
	if decor:
		decor.show()


func _set_door_element(element: ElementalType, dir: Direction) -> void:
	if element.is_blank(): return
	var decal = DOOR_DECALS[element.name].instantiate()
	add_child(decal)
	decal.global_position = get_portal(dir).global_position

func _mark_door_as_prev(dir: Direction) -> void:
	pass

func _connect_portal(dir: Direction, marker: Marker3D) -> void:
	var portal := get_portal(dir)
	portal.point_2 = marker
