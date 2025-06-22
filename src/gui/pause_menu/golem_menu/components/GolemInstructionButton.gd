extends HBoxContainer

signal selected()

var _instruction: GolemInstruction

func setup(instruction: GolemInstruction) -> void: 
	$NameLabel.text = instruction.instruction
	$SpinBox.suffix = instruction.suffix
	$SpinBox.max_value = instruction.max_value
	$SpinBox.step = instruction.step
	$SpinBox.value = instruction.value
	_instruction = instruction



func _on_gui_input(event:InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if (event as InputEventMouseButton).button_index == MouseButton.MOUSE_BUTTON_LEFT:
		return selected.emit()


func get_instruction() -> GolemInstruction:
	_instruction.value = $SpinBox.value
	return _instruction
