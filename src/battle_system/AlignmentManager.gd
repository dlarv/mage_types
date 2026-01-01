@tool
extends Resource
class_name AlignmentManager

enum Type { ATTACK, TRANSMUTATION, CHANNELING, OTHER }

const ALIGNMENT_THRESHOLD := 0xFF
const ATTACK_MOD := 3.0
const CHANNELING_MOD := 1.0
const TRANSMUTATION_MOD := 3.0

## Each value ranges from 0-255
@export var alignment_values: Array[int] = [ 0, 3, 0, 0, 0, 0, 0, 0 ]
@export var _alignment := ElementalType.ElementId.BLANK:
	set(val):
		_alignment = val
		current_alignment = ElementManager.elements[int(val)]
var current_alignment: ElementalType 
## Once an alignment forms, it cannot be overwritten.
var alignment_locked: bool:
	get:
		return not current_alignment.is_blank()

var _unnormalized_values: Array[float] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]


## val = ########, where # is a hex value between 0 and FF.
func setup_from_string(val: String) -> void:
	alignment_values = []
	for i in range(0, len(val) - 1, 2):
		var hex := val.substr(i, 2).hex_to_int()
		alignment_values.append(max(min(hex, ALIGNMENT_THRESHOLD), 0))
	update_current_alignment()


func add(key: ElementalType, amount:=1) -> void:
	if alignment_locked: return
	var index: int = ElementManager.get_index_from_name(key.name)
	alignment_values[index] += amount
	alignment_values[index] = max(min(alignment_values[index], ALIGNMENT_THRESHOLD), 0)


func append_unnormalized(key: ElementalType, type:=Type.OTHER, amount:=1.0) -> void:
	var mod := 1.0
	match type:
		Type.ATTACK: mod = ATTACK_MOD
		Type.TRANSMUTATION: mod = TRANSMUTATION_MOD
		Type.CHANNELING: mod = CHANNELING_MOD
		
	var index: int = ElementManager.get_index_from_name(key.name)
	_unnormalized_values[index] += amount * mod


## Find average of all unnormalized values, then +val/average.
func normalize_and_add() -> Array[float]:
	var average := 0.0

	var total := 0
	for val in _unnormalized_values:
		# average += val / 8.0
		if val > 0:
			average += val
			total += 1
	average /= total

	for i in len(_unnormalized_values):
		# var val: float = _unnormalized_values[i]
		var val: int = round(_unnormalized_values[i] / average)
		var element: ElementalType = ElementManager.elements[i]
		add(element, val)
		Logger.append_battle_log("%s: Unnorm(%f) / Average(%f) = +Delta(%d) => AlignmentValue(%d)" 
				% [element, _unnormalized_values[i], average, val, alignment_values[i]])
		# if val > average:
		# 	var element: ElementalType = ElementManager.elements[i]
		# 	add(element)
			# Logger.append_battle_log("%s: +1 = %d" % [element, alignment_values[i]])

	var output := _unnormalized_values.duplicate()
	_unnormalized_values = [0, 0, 0, 0, 0, 0, 0, 0 ]
	return output


## Returns an array containing whichever element(s) now has the highest value.
func update_current_alignment() -> Array[ElementalType]:
	if alignment_locked: return []

	var maxVal: int = alignment_values.max()

	var output: Array[ElementalType] = []
	for i in len(alignment_values):
		if alignment_values[i] == maxVal:
			output.append(ElementManager.elements[i])
	
	# If player's current primary type is in output, their core will not change.
	# However, if their alignment gets locked, this value is randomly selected.
	if maxVal == ALIGNMENT_THRESHOLD:
		alignment_locked = true
		current_alignment = output.pick_random()
		return [current_alignment]

	return output


func deserialize(data: Dictionary) -> void:
	if not data.is_empty(): 
		alignment_locked = data.alignment_locked
		setup_from_string(data.values)


func serialize() -> Dictionary:
	var output := ""
	for val in alignment_values:
		output += "%02x" % val
	return { "values": output, "alignment_locked": alignment_locked }
