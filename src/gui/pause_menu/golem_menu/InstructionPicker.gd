extends PopupPanel

const GolemInstructionButton := preload("components/golem_instruction_button.tscn")

@export var instructions: Array[GolemInstruction]
var selected_instruction: GolemInstruction = null


func _ready() -> void:
	for instruction in instructions:
		var button: Button = Button.new()
		button.text = instruction.instruction
		button.pressed.connect(_on_button_pressed.bind(instruction))
		%Scroller.add_child(button)


func _on_about_to_popup() -> void:
	position = get_viewport().get_mouse_position()
	selected_instruction = null


func _on_button_pressed(instruction: GolemInstruction) -> void:
	selected_instruction = instruction
	hide()
