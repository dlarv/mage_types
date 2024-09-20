@tool
extends ColorRect 
class_name ElementIcon 

@export
var label: RichTextLabel ;
@export
var Element : ElementalType:
	get: return _element;
	set(value):
		if(label == null): return;

		if(value == null):  _element = ElementManager.Blank; 
		else: _element = value; 
		label.text = "[center][color=%s]%s[/color][/center]" % [ _element.GetTextColor().to_html(), _element.Name ]
		color = _element.MainColor;

var _element: ElementalType 
