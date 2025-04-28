@tool
extends Control

const B_NODE := "0442b5"
const P_NODE := "6e5db7"
const M_NODE := "b350b4"
const R_NODE := "bb1a00"
const O_NODE := "b96206"
const Y_NODE := "b2ab3d"
const G_NODE := "47ae20"
const C_NODE := "5cafb0"

const B_EDGE := "1b48bd"
const P_EDGE := "7362bd"
const M_EDGE := "b955ba"
const R_EDGE := "c12205"
const O_EDGE := "bf670e"
const Y_EDGE := "b8b042"
const G_EDGE := "4db427"
const C_EDGE := "62b4b5"

@export var flow_chart: TextureRect
@export var advanced_options_parent: VBoxContainer
@export var element_selection_parent: VBoxContainer
@export var nodes_selection_parent: HBoxContainer

@export var elements_check_box_parent: VBoxContainer
@export var nodes_check_box_parent: VBoxContainer
@export var edges_check_box_parent: VBoxContainer

var _original_image: Image

func _ready() -> void:
	_original_image = flow_chart.texture.get_image().duplicate()
	restrict_graph([ElementManager.Orange, ElementManager.Yellow, ElementManager.Green, ElementManager.Cyan],
			[ElementManager.Yellow, ElementManager.Green])

func restrict_graph(nodes: Array, edges: Variant=null) -> void:
	if len(nodes) == 0 and edges == null:
		flow_chart.texture = ImageTexture.create_from_image(_original_image.duplicate())
		return

	flow_chart.texture = ImageTexture.create_from_image(_original_image.duplicate())
	var image: Image = flow_chart.texture.get_image()

	for i in range(len(nodes)):
		nodes[i] = nodes[i].name[0].to_lower()
	if edges and edges is Array:
		for i in range(len(edges)):
			edges[i] = edges[i].name[0].to_lower()
	var counter := {}
	var prevKey: String = ""
	var prevCol: Color
	for x in image.get_width():
		for y in image.get_height():
			var col := image.get_pixel(x, y)

			var alpha := col.to_html().substr(6, 2)

			if col.a <= 0.2: continue
			var key := col.to_html(false)

			if _is_restricted(key, nodes, edges):
				image.set_pixel(x, y, Color.BLACK)
			elif _is_orphan(alpha, nodes):
				image.set_pixel(x, y, Color.BLACK)
	


	
	flow_chart.texture.update(image)


func _is_restricted(key: String, nodes: Array, edges: Variant) -> bool:
	if edges == null:
		var val := find_closest(key)
		if val.is_empty(): return false 
		return val in nodes 

	match key:
		B_NODE:
			return "b" in nodes
		B_EDGE:
			return "b" in edges
		P_NODE:
			return "p" in nodes
		P_EDGE:
			return "p" in edges
		M_NODE:
			return "m" in nodes
		M_EDGE:
			return "m" in edges
		R_NODE:
			return "r" in nodes
		R_EDGE:
			return "r" in edges
		O_NODE:
			return "o" in nodes
		O_EDGE:
			return "o" in edges
		Y_NODE:
			return "y" in nodes
		Y_EDGE:
			return "y" in edges
		G_NODE:
			return "g" in nodes
		G_EDGE:
			return "g" in edges
		C_NODE:
			return "c" in nodes
		C_EDGE:
			return "c" in edges
			
	return false


func _is_orphan(alpha: String, nodes: Array) -> bool:
	var a := alpha.hex_to_int()
	#if a == 0xFF or a < 0xF2: return false
	match a:
		0xFC: return "b" in nodes or "c" in nodes
		0xFA: return "p" in nodes or "c" in nodes
		0xF7: return "b" in nodes or "p" in nodes
		0xF5: return "b" in nodes or "m" in nodes
		0xF2: return "p" in nodes or "m" in nodes
		0xF0: return "p" in nodes or "o" in nodes
		0xED: return "m" in nodes or "o" in nodes
		0xEB: return "m" in nodes or "r" in nodes
		0xE8: return "o" in nodes or "r" in nodes
		0xE6: return "o" in nodes or "y" in nodes
		0xE3: return "r" in nodes or "y" in nodes
		0xE0: return "g" in nodes or "y" in nodes
		0xDE: return "g" in nodes or "c" in nodes
		_: return false


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
	

func _on_options_button_pressed() -> void:
	advanced_options_parent.visible = not advanced_options_parent.visible


func _on_hide_elements_button_pressed() -> void:
	var nodes := []
	var edges: Variant = null

	if nodes_selection_parent.visible:
		var nodeCheckBoxes = nodes_check_box_parent.find_children("", "CheckBox")
		var edgeCheckBoxes = edges_check_box_parent.find_children("", "CheckBox")
		edges = []

		var i = -1
		for box in nodeCheckBoxes:
			i += 1
			if box.button_pressed:
				nodes.append(ElementManager.elements[i])

		i = -1
		for box in edgeCheckBoxes:
			i += 1
			if box.button_pressed:
				edges.append(ElementManager.elements[i])
		
	else:
		var checkBoxes = elements_check_box_parent.find_children("", "CheckBox")

		var i = -1
		for box in checkBoxes:
			i += 1
			if box.button_pressed:
				nodes.append(ElementManager.elements[i])

	restrict_graph(nodes, edges)


func _on_by_element_button_pressed() -> void:
	nodes_selection_parent.hide()
	element_selection_parent.show()


func _on_nodes_edges_button_pressed() -> void:
	element_selection_parent.hide()
	nodes_selection_parent.show()


func _on_clear_button_pressed() -> void:
	var checkBoxes = elements_check_box_parent.find_children("", "CheckBox")
	checkBoxes.append_array(nodes_check_box_parent.find_children("", "CheckBox"))
	checkBoxes.append_array(edges_check_box_parent.find_children("", "CheckBox"))

	for box in checkBoxes:
		box.button_pressed = false

	restrict_graph([])
