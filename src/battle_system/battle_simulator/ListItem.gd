extends HBoxContainer

signal pressed()

func _init(name: String="") -> void:
	var button := Button.new()
	button.text = "X"
	button.pressed.connect(func() -> void: pressed.emit())
	add_child(button)

	var label := Label.new()
	label.text = name
	add_child(label)
