@tool
extends ColorRect 
class_name ElementIcon 

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element := "blank": 
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)

var element: ElementalType:
	set(value):
		element = value
		if($Label == null): return

		if(value == null):  element = ElementManager.Blank 
		else: element = value 
		$Label.text = element.name
		color = element.main_color

		if color.get_luminance() < 0.5:
			$Label.label_settings.font_color = Color.WHITE
		else:
			$Label.label_settings.font_color = Color.BLACK
