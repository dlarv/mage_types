@tool
extends Resource
class_name AlignmentManager

enum Type { ATTACK, TRANSMUTATION, OTHER }
const ATTACK_MOD := 1.0
const TRANSMUTATION_MOD := 3.0

## Each value ranges from 0-F
var alignment_values: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0 ]
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _alignment: String = "blank":
	set(val):
		_alignment = val
		current_alignment = ElementManager.get_element_from_name(val)
var current_alignment: ElementalType
## Once an alignment forms, it cannot be overwritten.
@export var alignment_locked := false

var _unnormalized_values := [0, 0, 0, 0, 0, 0, 0, 0 ]


## val = ########, where # is a hex value between 0 and F.
func setup_from_string(val: String) -> void:
	alignment_values = []
	for i in len(val):
		alignment_values.append(max(min(val[i].hex_to_int(), 0xF), 0))
	update_current_alignment()


# index: ElementalType|int
func add(key: ElementalType, amount:=1) -> void:
	if alignment_locked: return
	var index: int = ElementManager.get_index_from_name(key.name)
	alignment_values[index] += amount
	alignment_values[index] = max(min(alignment_values[index], 0xF), 0)


func append_unnormalized(key: ElementalType, amount:=1.0, type:=Type.OTHER) -> void:
	var mod := 1.0
	match type:
		Type.ATTACK: mod = ATTACK_MOD
		Type.TRANSMUTATION: mod = TRANSMUTATION_MOD
		
	var index: int = ElementManager.get_index_from_name(key.name)
	_unnormalized_values[index] += amount * mod


## Find average of all unnormalized values, then +1 for all elements above this value.
## Returns true if a 
func normalize_and_add() -> bool:
	var average := 0.0

	for val in _unnormalized_values:
		average += val / 8.0
	for i in len(_unnormalized_values):
		var val: float = _unnormalized_values[i]
		if val > average:
			var element: ElementalType = ElementManager.elements[i]
			add(element)
			Logger.append_battle_log("%s: +1 = %d" % [element, alignment_values[i]])

	_unnormalized_values = [0, 0, 0, 0, 0, 0, 0, 0 ]
	return update_current_alignment()


## Returns true if alignment was locked during this call.
func update_current_alignment() -> bool:
	if alignment_locked: return false

	var maxIndex := -1
	var maxVal := -1

	for i in len(alignment_values):
		if maxVal < alignment_values[i] or maxVal == alignment_values[i] and randf() <= 0.5:
			maxVal = alignment_values[i]
			maxIndex = i
	
	# If there is a tie, the current alignment will always win.
	# Otherwise, tie breaker is determined above.
	if maxVal > 0 and alignment_values[ElementManager.get_index_from_name(current_alignment.name)] < maxVal:
		current_alignment = ElementManager.elements[maxIndex]
	if maxVal == 0xF:
		alignment_locked = true
	return alignment_locked


func deserialize(data: Dictionary) -> void:
	alignment_locked = data.alignment_locked
	setup_from_string(data.values)


func serialize() -> Dictionary:
	var output := ""
	for val in alignment_values:
		output += "%x" % val
	return { "values": output, "alignment_locked": alignment_locked }
