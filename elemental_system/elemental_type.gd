extends Node
class_name ElementalType

var type_name: String
var color: Color

func _init(type_name: String, color: Color):
	self.type_name = type_name
	self.color = color

static func max(a: ElementalType, b: ElementalType):
	if a.color.to_rgba64() > b.color.to_rgba64():
		return a
	return b

static func min(a: ElementalType, b: ElementalType):
	if a.color.to_rgba64() < b.color.to_rgba64():
		return a
	return b

