extends Resource

@export var _element := ElementalType.ElementId.BLANK:
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
var element: ElementalType
@export var rand_val: int
@export var emitter_puzzle_name: String
