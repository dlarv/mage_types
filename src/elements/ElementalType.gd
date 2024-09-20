@tool
extends Resource
class_name ElementalType 

@export
var Name: String ;
@export
var MainColor: Color ;
@export
var TextColor: Color ;
@export
var ColorPalette = []

func _init():
	Name = "Blank";
	MainColor = Color(.5, .5, .5);
	ColorPalette = []
	TextColor = Color.BLACK;

func GetTextColor()-> Color:
	return TextColor;
