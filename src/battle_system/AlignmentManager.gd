@tool
extends Resource
class_name AlignmentManager

enum Type { ATTACK, TRANSMUTATION, CHANNELING, OTHER }

const ALIGNMENT_THRESHOLD := 0xF
const ATTACK_MOD := 3.0
const CHANNELING_MOD := 1.0
const TRANSMUTATION_MOD := 3.0

## Each value ranges from 0-255
@export var alignment_values: Array[int] = [ 0, 3, 0, 0, 0, 0, 0, 0 ]
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _alignment: String = "blank":
	set(val):
		_alignment = val
		current_alignment = ElementManager.get_element_from_name(val)
var current_alignment: ElementalType
## Once an alignment forms, it cannot be overwritten.
@export var alignment_locked := false

var _unnormalized_values: Array[float] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]


## val = ########, where # is a hex value between 0 and FF.
func setup_from_string(val: String) -> void:
	alignment_values = []
	for i in len(val) - 1:
		alignment_values.append(max(min(val.substr(i, 2).hex_to_int(), ALIGNMENT_THRESHOLD), 0))
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
	if maxVal == ALIGNMENT_THRESHOLD:
		alignment_locked = true
	return alignment_locked


func deserialize(data: Dictionary) -> void:
	if not data.is_empty(): 
		alignment_locked = data.alignment_locked
		setup_from_string(data.values)


func serialize() -> Dictionary:
	var output := ""
	for val in alignment_values:
		output += "%02x" % val
	return { "values": output, "alignment_locked": alignment_locked }
