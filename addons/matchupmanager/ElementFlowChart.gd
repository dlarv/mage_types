@tool
extends Control

@onready var BLUE := ElementManager.Blue
@onready var PURPLE := ElementManager.Purple
@onready var MAGENTA := ElementManager.Magenta
@onready var RED := ElementManager.Red
@onready var ORANGE := ElementManager.Orange
@onready var YELLOW := ElementManager.Yellow
@onready var GREEN := ElementManager.Green
@onready var CYAN := ElementManager.Cyan

var stencil_shader: ShaderMaterial
var _original_image: Image

func _ready() -> void:
	stencil_shader = %TextureRect.material
	%AdvancedOptionsPane.visible = Settings.debug_mode and not Settings.play_test_mode

	# if Settings.play_test_mode:
	# 	_on_stencil_button_toggled(true, 1)
	
	if not Inventory.key_item_obtained.is_connected(activate_stencil):
		Inventory.key_item_obtained.connect(activate_stencil)
	if not Inventory.key_item_lost.is_connected(deactivate_stencil):
		Inventory.key_item_lost.connect(deactivate_stencil)
	
	var _editor := Engine.is_editor_hint()
	%StencilVBox.get_child(0).visible = _editor or Inventory.has_key_item(&"TUTORIAL_PACKET")
	%StencilVBox.get_child(1).visible = _editor or Inventory.has_key_item(&"TUTORIAL_PACKET")
	%StencilVBox.get_child(2).visible = _editor or Inventory.has_key_item(&"TUTORIAL_PACKET")

	for i in %StencilVBox.get_child_count() - 3:
		%StencilVBox.get_child(i + 3).visible = _editor or Inventory.has_key_item(&"STENCIL_%d" % i)
	

func restrict_graph(nodes: Array, edges:=[]) -> void:
	# Skip last element, which is Blank.
	for element in ElementManager.elements.slice(0, 8):
		var prefix := "HIDE_%s" % element.name[0].to_upper()
		stencil_shader.set_shader_parameter("%s_NODE" % prefix, element in nodes)
		stencil_shader.set_shader_parameter("%s_EDGE" % prefix, element in edges)


func activate_stencil(item: KeyItem) -> void:
	if item.unique_name == &"TUTORIAL_PACKET":
		%StencilVBox.get_child(0).show()
		%StencilVBox.get_child(1).show()
		%StencilVBox.get_child(2).show()
		_on_stencil_button_toggled(true, 0)
		%StencilVBox.get_child(0).set_pressed_no_signal(true)
		return

	if item.unique_name.find("STENCIL") == -1: return
	var index := item.id
	if index < 0 or index >= %StencilVBox.get_child_count():
		push_warning("Tried to activate Stencil(%d), but it does not exist" % index)
		return
	%StencilVBox.get_child(index + 3).visible = true
	_on_stencil_button_toggled(true, index + 3)
	%StencilVBox.get_child(index + 3).set_pressed_no_signal(true)


func deactivate_stencil(item: KeyItem) -> void:
	if item.unique_name.find("STENCIL") == -1: return
	var index := item.id
	if index < 0 or index >= %StencilVBox.get_child_count():
		push_warning("Tried to deactivate Stencil(%d), but it does not exist" % index)
		return
	%StencilVBox.get_child(index).visible = false

	_on_clear_button_pressed()
	%StencilVBox.get_child(index).set_pressed_no_signal(false)


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


func _on_stencil_button_toggled(toggledOn: bool, index: int) -> void:
	if not toggledOn:
		_on_clear_button_pressed()
		return

	var nodes: Array[ElementalType]
	var edges: Array[ElementalType]
	match index:
		0: 
			nodes = [ BLUE, PURPLE,MAGENTA, YELLOW, GREEN, CYAN ]
			edges = [ MAGENTA, ORANGE ]
		1:
			nodes = [ BLUE, PURPLE, MAGENTA, GREEN, CYAN ]
			edges = [ MAGENTA ]
		2:
			nodes = [ BLUE, YELLOW, GREEN, CYAN ]
			edges = [ MAGENTA, ORANGE ]
		3:
			nodes = [ RED, ORANGE, YELLOW, GREEN, CYAN ]
			edges = [ ORANGE, YELLOW, GREEN ]

	restrict_graph(nodes, edges)

	if not %AdvancedOptionsPane.is_visible_in_tree(): return

	var checkBoxes := %NodesVBox.find_children("", "CheckBox")
	for node in nodes:
		checkBoxes[int(node.id)].set_pressed_no_signal(true)

	checkBoxes = %EdgesVBox.find_children("", "CheckBox")
	for edge in edges:
		checkBoxes[int(edge.id)].set_pressed_no_signal(true)
