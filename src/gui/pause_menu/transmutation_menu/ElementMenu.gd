extends Menu

@export var flow_chart: TextureRect
@export var check_box_parent: VBoxContainer

var _original_image: Image

func _ready() -> void:
	_original_image = flow_chart.texture.get_image().duplicate()


func restrict_graph(restrictedElements: Array) -> void:
	if len(restrictedElements) == 0:
		flow_chart.texture = ImageTexture.create_from_image(_original_image.duplicate())
		return

	flow_chart.texture = ImageTexture.create_from_image(_original_image.duplicate())
	var image: Image = flow_chart.texture.get_image()

	for i in range(len(restrictedElements)):
		restrictedElements[i] = restrictedElements[i].name[0].to_lower()

	for x in image.get_width():
		for y in image.get_height():
			var col := image.get_pixel(x, y)
			if col.a < 0.2: continue

			var key := col.to_html().trim_suffix("ff")
			var val := find_closest(key)
			if val.is_empty(): continue

			if val in restrictedElements:
				image.set_pixel(x, y, Color.BLACK)
	flow_chart.texture.update(image)


func find_closest(hex: String) -> String:
	var r := hex.substr(0, 2).hex_to_int()
	var g := hex.substr(2, 2).hex_to_int()
	var b := hex.substr(4, 2).hex_to_int()
	var threshold := 0xA0

	if r >= threshold and g >= threshold:
		return "y"
	elif r >= threshold and b >= threshold:
		return "m"
	elif r >= threshold and g >= threshold / 2.0:
		return "o"
	elif g >= threshold and b >= threshold:
		return "c"
	elif r >= threshold / 2.0 and b >= threshold:
		return "p"
	elif r >= threshold:
		return "r"
	elif g >= threshold:
		return "g"
	elif b >= threshold:
		return "b"
	return ""


func _on_button_pressed() -> void:
	var checkBoxes = check_box_parent.find_children("", "CheckBox")

	var i = -1
	var elements := []
	for box in checkBoxes:
		i += 1
		if box.button_pressed:
			elements.append(ElementManager.elements[i])
	
	restrict_graph(elements)

	
func _on_options_button_pressed() -> void:
	check_box_parent.visible = not check_box_parent.visible

