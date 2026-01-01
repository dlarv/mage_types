@tool
extends ColorRect 
class_name ElementIcon 

@export var _element := ElementalType.ElementId.BLANK: 
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]

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
