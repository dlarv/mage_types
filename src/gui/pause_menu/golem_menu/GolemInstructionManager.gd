extends VBoxContainer

const GolemInstructionButton := preload("components/golem_instruction_button.tscn")


func _on_instruction_picker_button_pressed() -> void:
	$InstructionPicker.show()



func _on_instruction_picker_popup_hide() -> void:
	var instruction: GolemInstruction = $InstructionPicker.selected_instruction
	if not instruction: return

	var button := GolemInstructionButton.instantiate()
	button.setup(instruction)
	button.removed.connect(func():
		var b = button
		%Scroller.remove_child(b))
	%Scroller.add_child(button)


func get_instructions() -> Array:
	var output := []

	for child in %Scroller.get_children():
		output.append(child.get_instruction())

	return output
