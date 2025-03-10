@tool
extends MarginContainer

@export var b_icon: ElementIcon
@export var p_icon: ElementIcon
@export var m_icon: ElementIcon
@export var r_icon: ElementIcon
@export var o_icon: ElementIcon
@export var y_icon: ElementIcon
@export var g_icon: ElementIcon
@export var c_icon: ElementIcon

var laser_sequence := [null,null,null,null,null,null,null,]

func _on_element_dropdown_item_selected(elementIndex:int, index:int) -> void:
	laser_sequence[index] = elementIndex

func _on_calculate_button_pressed() -> void:
	var resultIcons := [b_icon,p_icon,m_icon,r_icon,o_icon,y_icon,g_icon,c_icon]

	var i := -1
	for startingElement in ElementManager.elements:

		i += 1
		var element = startingElement

		for j in laser_sequence:
			if j == null or j == 0: continue
			var laserElement := ElementManager.elements[j - 1]
			if laserElement.is_blank(): continue

			var e = ElementManager.get_matchup(element, laserElement)
			if e != null:
				element = e

		resultIcons[i].element = element
