@tool
extends Resource
class_name ElementalType 

@export var name: String 
@export var main_color: Color 
@export var is_defensive_type: bool
@export var text_color: Color 
@export var color_palette: Array[Color]

func _init() -> void:
	name = "Blank" 
	main_color = Color(.5, .5, .5)
	color_palette = []
	text_color = Color.BLACK


func get_text_color()-> Color:
	return text_color


func get_bb_code_name(useAltColor:=false) -> String:
	if useAltColor:
		return "[color=%s]%s[/color]" % [text_color.to_html(), name]
	return "[color=%s]%s[/color]" % [main_color.to_html(), name]


func is_blank() -> bool:
	return name == "Blank"


func get_off_def_color() -> Color:
	if is_defensive_type:
		return Color.BLUE
	return Color.RED

func get_affinity_bb_code_name(capitalize: bool) -> String:
	if is_defensive_type:
		return "[color=blue]%s[/color]" % ("Defensive" if capitalize else "defensive")
	return "[color=red]%s[/color]" % ("Offensive" if capitalize else "offensive")


func in_same_affinity_group(el: ElementalType) -> bool:
	return not is_blank() and not el.is_blank() and is_defensive_type == el.is_defensive_type


func _to_string() -> String:
	return name
