@tool
extends MarginContainer

@export var spells_vbox: VBoxContainer
@export var terrains_vbox: VBoxContainer
@export var objects_vbox: VBoxContainer
@export var popup: AcceptDialog
@export var display_parent: Control


func _on_calculate_button_pressed() -> void:
	var spell_elements := []
	var terrain_elements := []
	var object_elements := []

	for child in spells_vbox.get_children():
		if child is Label: continue
		if child.pressed:
			spell_elements.append(child.element)
	
	for child in terrains_vbox.get_children():
		if child is Label: continue
		if child.pressed:
			terrain_elements.append(child.element)

	for child in objects_vbox.get_children():
		if child is Label: continue
		if child.pressed:
			object_elements.append(child.element)

	# Add spell elements gained from bouncing spells off of terrain.
	for element in spell_elements:
		for terrain in terrain_elements:
			var result := ElementManager.get_matchup(element, terrain)
			if result != null and not result in spell_elements:
				spell_elements.append(result)
	
	# Generate a graph for each AlchemicObject.
	var graphs := {}
	var displays := display_parent.get_children()

	for display in displays:
		var originalElement := ElementManager.get_element_from_name(display.name)
		var elements := [originalElement]

		# Hide tabs that aren't relevant.
		if not originalElement in object_elements:
			display_parent.move_child(display, -1)
			display.get_child(0).hide()
			continue
		display.get_child(0).show()

		var graph := {}
		graphs[originalElement] = graph

		for element in elements:
			for spell in spell_elements:
				var result := ElementManager.get_matchup(element, spell)
				if result == null: continue
				graph[[element, result]] = null
				if not result in elements:
					elements.append(result)
		display.get_child(0).draw_graph(graph, elements)

	display_parent.current_tab = 0

class ElementalNode:
	var element : ElementalType = ElementManager.Blank
	# Dict<ElementalType, ElementalNode>
	var edges = {}

	func _init(element: ElementalType) -> void:
		self.element = element
	
	func add_connection(element: ElementalType, result: ElementalNode) -> void:
		edges[element] = result


