extends Control


# elements: Array[ElementalType]
func setup(data: Variant) -> void:
	%NameLabel.text = data[0].name
	%ElementIcon.element = data[1]
	%ElementIcon2.element = data[2]
	%ElementIcon3.element = data[3]
