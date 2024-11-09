@tool
extends GridContainer

const E := Color.WHITE
const B := Color.BLACK
const G := Color.GRAY

@export_enum("empty", "color", "dash_h", "dash_/", "dash_\\", "dash_v", "arrow_l", "arrow_r", "arrow_tr", "arrow_tl", "arrow_br", "arrow_bl", "arrow_d", "arrow_u")
var type: String: set = _set_type
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blank
var is_empty: bool:
	get():
		return type == "empty" or _overridden == "empty"
var _overridden = ""


const EMPTY := [
	E,E,E,E,E,
	E,E,E,E,E,
	E,E,E,E,E,
	E,E,E,E,E,
	E,E,E,E,E,
]
const ARROW_U := [
	E,E,B,E,E,
	E,B,B,B,E,
	E,E,B,E,E,
	E,E,B,E,E,
	E,E,B,E,E,
]
const ARROW_D := [
	E,E,B,E,E,
	E,E,B,E,E,
	E,E,B,E,E,
	E,B,B,B,E,
	E,E,B,E,E,
]
const ARROW_BR := [
	B,E,E,E,E,
	E,B,E,E,E,
	E,E,B,E,B,
	E,E,E,B,B,
	E,E,B,B,B,
]
const ARROW_BL := [
	E,E,E,E,B,
	E,E,E,B,E,
	B,E,B,E,E,
	B,B,E,E,E,
	B,B,B,E,E,
]
const ARROW_TL := [
	B,B,B,E,E,
	B,B,E,E,E,
	B,E,B,E,E,
	E,E,E,B,E,
	E,E,E,E,B,
]
const ARROW_TR := [
	E,E,B,B,B,
	E,E,E,B,B,
	E,E,B,E,B,
	E,B,E,E,E,
	B,E,E,E,E,
]
const ARROW_R := [
	E,E,E,E,E,
	E,E,E,B,E,
	B,B,B,B,B,
	E,E,E,B,E,
	E,E,E,E,E,
]
const ARROW_L := [
	E,E,E,E,E,
	E,B,E,E,E,
	B,B,B,B,B,
	E,B,E,E,E,
	E,E,E,E,E,
]
const DASH_U := [
	E,E,E,E,B,
	E,E,E,B,E,
	E,E,B,E,E,
	E,B,E,E,E,
	B,E,E,E,E,
]
const DASH_D := [
	B,E,E,E,E,
	E,B,E,E,E,
	E,E,B,E,E,
	E,E,E,B,E,
	E,E,E,E,B,
]
const DASH_H := [
	E,E,E,E,E,
	E,E,E,E,E,
	B,B,B,B,B,
	E,E,E,E,E,
	E,E,E,E,E,
]
const DASH_V := [
	E,E,B,E,E,
	E,E,B,E,E,
	E,E,B,E,E,
	E,E,B,E,E,
	E,E,B,E,E,
]

func _ready():
	if type == "color":
		_set_type("color")

func _set_type(value: String) -> void:
	type = value
	var layout: Array
	match value:
		"color":
			layout = []
			layout.resize(25)
			layout.fill(element.main_color)
		"dash_h":
			layout = DASH_H
		"dash_/":
			layout = DASH_U
		"dash_\\":
			layout = DASH_D
		"dash_v":
			layout = DASH_V
		"arrow_l":
			layout = ARROW_L
		"arrow_r":
			layout = ARROW_R
		"arrow_tr":
			layout = ARROW_TR
		"arrow_tl":
			layout = ARROW_TL
		"arrow_br":
			layout = ARROW_BR
		"arrow_bl":
			layout = ARROW_BL
		"arrow_u":
			layout = ARROW_U
		"arrow_d":
			layout = ARROW_D
		"empty",_:
			layout = EMPTY
	
	var i := 0 
	for child in get_children():
		child.color = layout[i]
		i += 1

func override_to_empty() -> void:
	_overridden = "empty"
	var i := 0 
	for child in get_children():
		child.color = EMPTY[i]
		i += 1

func override_to_dash() -> void:
	var layout: Array
	_overridden = "dash"
	match type:
		"arrow_l","arrow_r":
			layout = DASH_H
		"arrow_tr","arrow_bl":
			layout = DASH_U
		"arrow_tl","arrow_br":
			layout = DASH_D
		"arrow_u","arrow_d":
			layout = DASH_V

	var i := 0 
	for child in get_children():
		var color = layout[i]
		if color == B:
			color = G
		child.color = color
		i += 1

func clear_override() -> void:
	_overridden = ""
	_set_type(type)

func mark_as_softlock() -> void:
	if type != "color": return
	var i := 0
	for cell in get_children():
		if i < 5 or i > 20 or i % 5 == 0 or i % 5 == 4:
			cell.color = Color.DARK_RED
		i += 1

func unmark_softlock() -> void:
	if type != "color": return
	for cell in get_children().slice(-5):
		cell.color = element.main_color
