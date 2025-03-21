@tool
extends MarginContainer

@export var result_icons: Array[ElementIcon]
@export var result_labels: Array[Label]

var laser_sequence := [null,null,null,null,null,null,null,]

func _on_element_dropdown_item_selected(elementIndex:int, index:int) -> void:
	laser_sequence[index] = elementIndex

func _on_calculate_button_pressed() -> void:
	var i := -1
	for startingElement in ElementManager.elements:

		i += 1
		var element = startingElement
		var reactionCount := 0

		for j in laser_sequence:
			if j == null or j == 0: continue
			var laserElement := ElementManager.elements[j - 1]
			if laserElement.is_blank(): continue

			var e = ElementManager.get_matchup(element, laserElement)
			if e != null:
				element = e
				reactionCount += 1

		result_icons[i].element = element
		result_labels[i].text = "%d ==>" % reactionCount
