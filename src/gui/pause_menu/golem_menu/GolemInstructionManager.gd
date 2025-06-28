extends Control

const GolemInstructionButton := preload("components/golem_instruction_button.tscn")

@export var instructions: Array[GolemInstruction]


func get_instructions() -> Array:
	var output := []

	for child in %Scroller.get_children():
		output.append(child.get_instruction())

	return output


func _select_instruction(index: int) -> void:
	var button := GolemInstructionButton.instantiate()
	button.setup(instructions[index])
	button.removed.connect(func():
		var b = button
		%Scroller.remove_child(b))
	%Scroller.add_child(button)
