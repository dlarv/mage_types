@tool
extends ColorRect 
class_name ElementIcon 

@export
var label: RichTextLabel 
@export
var element : ElementalType:
	get: return _element
	set(value):
		if(label == null): return

		if(value == null):  _element = ElementManager.Blank 
		else: _element = value 
		label.text = "[center][color=%s]%s[/color][/center]" % [ _element.get_text_color().to_html(), _element.name ]
		color = _element.main_color

var _element: ElementalType 
