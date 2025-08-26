@tool
extends Control

var stencil_shader: ShaderMaterial
var _original_image: Image

func _ready() -> void:
	stencil_shader = %TextureRect.material
	%AdvancedOptionsPane.visible = Settings.debug_mode

	if Settings.play_test_mode:
		restrict_graph([ElementManager.Yellow, ElementManager.Green, ElementManager.Cyan],
				[ElementManager.Green])


func restrict_graph(nodes: Array, edges:=[]) -> void:
	for element in ElementManager.elements:
		var prefix := "HIDE_%s" % element.name[0].to_upper()
		stencil_shader.set_shader_parameter("%s_NODE" % prefix, element in nodes)
		stencil_shader.set_shader_parameter("%s_EDGE" % prefix, element in edges)


func _on_options_button_pressed() -> void:
	%AdvancedOptionsVBox.visible = not %AdvancedOptionsVBox.visible


func _on_hide_elements_button_pressed() -> void:
	var nodes := []
	var edges := []

	var i = -1
	for box in %NodesVBox.find_children("", "CheckBox"):
		i += 1
		if box.button_pressed:
			nodes.append(ElementManager.elements[i])

	i = -1
	for box in %EdgesVBox.find_children("", "CheckBox"):
		i += 1
		if box.button_pressed:
			edges.append(ElementManager.elements[i])

	restrict_graph(nodes, edges)


func _on_clear_button_pressed() -> void:
	var checkBoxes = %NodesVBox.find_children("", "CheckBox")
	checkBoxes.append_array(%EdgesVBox.find_children("", "CheckBox"))

	for box in checkBoxes:
		box.button_pressed = false

	restrict_graph([])
