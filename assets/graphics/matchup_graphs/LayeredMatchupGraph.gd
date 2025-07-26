@tool
extends SubViewportContainer

@export var offset: Vector3:
	set(val):
		offset = val
		if not is_inside_tree(): return
		$SubViewport/Node3D.global_position = val

var camera: Camera3D: 
	get:
		return $SubViewport/Node3D/Camera3D

func hide_edge(startNode: ElementalType, endNode: ElementalType, edgeColor: ElementalType=null) -> void:
	_find_component(startNode, endNode, edgeColor).visible = false


func show_edge(startNode: ElementalType, endNode: ElementalType, edgeColor: ElementalType=null) -> void:
	_find_component(startNode, endNode, edgeColor).visible = true

func hide_node(node: ElementalType) -> void:
	_find_component(node).hide()
	
func show_node(node: ElementalType) -> void:
	_find_component(node).show()

func hide_all() -> void:
	for child in $"SubViewport/Node3D/matchup_graph_v3".get_children():
		child.hide()

func show_all() -> void:
	for child in $"SubViewport/Node3D/matchup_graph_v3".get_children():
		child.show()

func _find_component(startNode: ElementalType, endNode: ElementalType = null, edgeColor: ElementalType=null) -> Node:
	var nodeName := startNode.name[0].to_upper()
	if endNode != null:
		nodeName += endNode.name[0].to_upper()

		if find_child(nodeName) == null:
			if edgeColor != null:
				nodeName += "_%s" % edgeColor.name[0].to_upper()

	
	return get_node("SubViewport/Node3D/matchup_graph_v3/%s" % nodeName)
