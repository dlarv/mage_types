@tool
extends TabContainer

var head: MirrorGraphNode

func _on_button_pressed() -> void:
	var startElement: ElementalType = ElementManager.elements[%ElementDropdown.selected]
	var elements := []

	for ch in %LineEdit.text.to_upper():
		match ch:
			'B': elements.append(ElementManager.Blue)
			'P': elements.append(ElementManager.Purple)
			'M': elements.append(ElementManager.Magenta)
			'R': elements.append(ElementManager.Red)
			'O': elements.append(ElementManager.Orange)
			'Y': elements.append(ElementManager.Yellow)
			'G': elements.append(ElementManager.Green)
			'C': elements.append(ElementManager.Cyan)
			_: push_warning("Ch(%s) does not map to valid element." % ch)

	head = MirrorGraphNode.new(startElement, elements)


class MirrorGraphNode:
	# Dict<Element, Node>
	var edges := {}
	var element: ElementalType

	func _init(e: ElementalType=null, elements:=[]):
		element = e
		edges = {}

		for element in elements:
			var result := ElementManager.get_matchup(e, element)
			if result == null: continue

			edges[element] = MirrorGraphNode.new(result, elements.filter(func(el):
				return el != element))

