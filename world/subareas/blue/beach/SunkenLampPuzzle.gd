extends Node3D

const HINT_COUNT := 4
## Chance that hitting reset trigger will cause a hint sequence to start, if one hasn't started already
const RESET_HINT_SEQUENCE_TRIGGER := 0.5
const Lamppost := preload("res://src/overworld/Lamp.gd")
enum PuzzleStates { SEQUENCE_START, HINT_PAUSE, HINTING, SEQUENCE_END }

@export var correct_sequence: Array[int]
@export var reward_node: Node3D

@export_category("Hint Timing")
@export var hint_sequence_delay := 10.0
@export var hint_start_delay := 1.0
## How long should a lamp be lit during hint
@export var hint_hold_time := 3.0
## How long should every lamp be turned off between hints
@export var hint_between_time := 0.5
## how bright should lamp be during hint
@export var hint_brightness := 25.0

var lamps: Array[Lamppost]

var _curr_sequence: Queue
var _curr_state := PuzzleStates.SEQUENCE_START
var _curr_hint_index: int

func _ready() -> void:
	_curr_sequence = Queue.new()
	if reward_node:
		reward_node.hide()
		reward_node.process_mode = Node.PROCESS_MODE_DISABLED

	var idx := 0
	for child in get_children():
		if not child is Lamppost: continue
		lamps.append(child)
		var area3d := child.find_child("Area3D")
		area3d.body_entered.connect(_on_island_entered.bind(idx))
		idx += 1
	
	_setup_next_sequence()


func _on_island_entered(body: Node3D, id: int) -> void:
	_curr_sequence.append(id)

	if _curr_sequence.equals(correct_sequence):
		MyLogger.append_puzzle_log("Sunken Lamp Puzzle Solved!")
		reward_node.show()
		reward_node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		MyLogger.append_puzzle_log("Sunken Lamp Puzzle failed! Correct(%s), Actual(%s)" 
				% [correct_sequence, _curr_sequence])


## This function could be deprecated, since _curr_sequence was changed from an list to a queue
## But it stays, at least for now, since it acts as a good trigger to help the player see the sequence happen
func _reset(body: Node3D) -> void:
	MyLogger.append_puzzle_log("Sunken Lamp Puzzle Reset")

	if randf() < RESET_HINT_SEQUENCE_TRIGGER and _curr_state == PuzzleStates.SEQUENCE_START:
		_sequence_start()


func _on_timer_timeout() -> void:
	match _curr_state:
		PuzzleStates.SEQUENCE_START:
			_sequence_start()
		PuzzleStates.HINT_PAUSE:
			_hint_start()
		PuzzleStates.HINTING:
			var idx := correct_sequence[_curr_hint_index]
			lamps[idx].light.light_energy = 0
			$Timer.wait_time = hint_between_time
			_curr_state = PuzzleStates.HINT_PAUSE
			$Timer.start()
		PuzzleStates.SEQUENCE_END:
			_setup_next_sequence()


func _sequence_start() -> void:
	MyLogger.append_puzzle_log("Sunken Lamppost Puzzle: starting next sequence")
	# Turn off all lights at once
	for lamp in lamps:
		lamp.disabled = true
		lamp.light.light_energy = 0
	
	$Timer.wait_time = hint_start_delay
	_curr_state = PuzzleStates.HINT_PAUSE
	$Timer.start()


func _hint_start() -> void:
	_curr_hint_index += 1
	if _curr_hint_index >= HINT_COUNT:
		_curr_state = PuzzleStates.SEQUENCE_END
		$Timer.wait_time = hint_hold_time
		$Timer.start()
		return

	var idx := correct_sequence[_curr_hint_index]
	MyLogger.append_puzzle_log("Sunken Lamppost Puzzle: showing Hint(%d), Lamp(%d)" % [_curr_hint_index, idx])

	_curr_state = PuzzleStates.HINTING
	$Timer.wait_time = hint_hold_time
	lamps[idx].light.light_energy = hint_brightness
	$Timer.start()
	

func _setup_next_sequence() -> void:
	MyLogger.append_puzzle_log("Sunken Lamppost Puzzle: in-between sequences")
	for lamp in lamps:
		lamp.disabled = false

	_curr_state = PuzzleStates.SEQUENCE_START
	_curr_hint_index = -1
	$Timer.wait_time = hint_sequence_delay
	$Timer.start()


class Queue:
	var _list: Array[int] = [0, 0, 0, 0]

	func append(num: int) -> void:
		if num == _list[-1]: return
		_list.pop_front()
		_list.append(num)

	func equals(other: Array[int]) -> bool:
		return _list == other

	func _to_string() -> String:
		return str(_list)
