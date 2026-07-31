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
		if value == null:  element = ElementManager.Blank 
		color = element.main_color
		_luminance_mod = Color.WHITE if color.get_luminance() < 0.5 else Color.BLACK
		_set_label()
		_set_icon()

var _luminance_mod: Color

# For some reason these unique names are null at times
@onready var _label = %Label
@onready var _icon = %TextureRect


func _ready() -> void:
	_set_label()
	_set_icon()


func _set_label() -> void:
	if not _label: return
	%Label.text = element.name
	%Label.label_settings.font_color = _luminance_mod


func _set_icon() -> void:
	if not _icon: return
	%TextureRect.texture = element.icon
	%TextureRect.modulate = _luminance_mod
