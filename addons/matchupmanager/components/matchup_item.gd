@tool
extends HBoxContainer

signal debuff_selected(index: int)
signal buff_selected(index: int)

var color_rect_1: ColorRect
var color_rect_2: ColorRect
var color_rect_3: ColorRect

func _enter_tree():
	get_node("SideEffectOptions1").item_selected.connect(func(index): buff_selected.emit(index))
	get_node("SideEffectOptions2").item_selected.connect(func(index): debuff_selected.emit(index))

func set_colors(e1: ElementalType, e2: ElementalType, e3: ElementalType):
	color_rect_1 = get_node("ColorRect1")
	color_rect_2 = get_node("ColorRect2")
	color_rect_3 = get_node("ColorRect3")

	color_rect_1.color = e1.MainColor
	color_rect_2.color = e2.MainColor
	color_rect_3.color = e3.MainColor

func set_side_effects(buff_index, debuff_index):
	get_node("SideEffectOptions1").selected = buff_index
	get_node("SideEffectOptions2").selected = debuff_index
