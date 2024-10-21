@tool
extends ColorRect 
class_name ElementIcon 

@export var label: RichTextLabel 
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element := "blank": 
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType:
	set(value):
		element = value
		if(label == null): return

		if(value == null):  element = ElementManager.Blank 
		else: element = value 
		label.text = "[center]%s[/center]" % element.get_bb_code_name(true)
		color = element.main_color
