@tool
extends MarginContainer

const ORIGINAL_GRAPH_PATH = "res://assets/graphics/matchup_graph_v3.png"
@export var original_graph: CompressedTexture2D
@export var result_rect_1: Control
@export var result_rect_2: Control
@export var result_rect_3: Control
@export var result_rect_4: Control

@export var _magiclay_parent: VBoxContainer
@export var _catalyst_parent: GridContainer

var _magiclay := []
var _catalysts := []


func _ready() -> void:
	_magiclay = []
	for child in _magiclay_parent.get_children():
		if child is Label: continue
		_magiclay.append(child)

	_catalysts = []
	for child in _catalyst_parent.get_children():
		if child is Label: continue
		_catalysts.append(child)



func _on_calculate_button_pressed() -> void:
	var results := [result_rect_1, result_rect_2, result_rect_3,result_rect_4]  

	var catalystElements := []
	for catalyst in _catalysts:
		var index = catalyst.selected
		if index != 0:
			catalystElements.append(ElementManager.elements[index - 1])

	var i := -1
	for clay in _magiclay:
		i += 1
		if clay == null: continue
		var result = results[i]
		result.hide_all()
		result.camera.make_current()

		var element := ElementManager.elements[clay.selected]
		traverse(element, catalystElements, result)



func traverse(element: ElementalType, validEdges: Array, graph: Node, visited:=[]) -> void:
	if element in visited: return
	var elementalNode = ElementManager.matchups[element.name]
	graph.show_node(element)
	visited.append(element)

	for e2 in elementalNode.edges.keys():
		if e2 in validEdges:
			var end = elementalNode.edges[e2].result.element
			graph.show_edge(element, end, e2)
			traverse(end, validEdges, graph, visited)
