extends Node

@export var dialog_data: Array[DialogueData]

func export_variable(varName: String, value: Variant) -> void:
	for data in dialog_data:
		data.variables[varName].value = value


func reload() -> void:
	# TODO
	pass
