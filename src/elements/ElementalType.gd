@tool
extends Resource
class_name ElementalType 

@export
var name: String ;
@export
var main_color: Color ;
@export
var text_color: Color ;
@export
var color_palette = []

func _init():
	name = "Blank"; main_color = Color(.5, .5, .5);
	color_palette = []
	text_color = Color.BLACK;

func get_text_color()-> Color:
	return text_color;
