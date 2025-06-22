@tool
extends Resource
class_name GolemInstruction

@export var instruction: String:
	set(val):
		instruction = val
		resource_name = val
@export var value := 0.0
@export var min_value := 1.0
@export var max_value := 99.0
@export var step := 1.0
@export var suffix := ""
