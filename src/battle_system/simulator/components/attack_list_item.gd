extends Control

@export var type_display: ColorRect
@export var name_display: Label
@export var range_display: Label
@export var power_display: Label
@export var button: Button

func create(attack):
	# If the parameter is given a type (i.e. attack: Attack),
	# then the following line throws the "Native class ElementalType not found" error.
	type_display.color = attack.Element.MainColor
	name_display.text = attack.Name
	power_display.text = str(attack.Power)
	
	if attack.Range == 0:
		range_display.text = "M"
	else:
		range_display.text = "R"
	
	return button
