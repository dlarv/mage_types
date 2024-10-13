@tool
extends Control

@export var grid: GridContainer

var _elements := []
var _matchups := {}

func _ready():
	if grid == null: return

	ElementManager.force_load()
	_elements = ElementManager.elements

	create_grid()


func create_grid(mirror:=false) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
	
	# Add empty spacer to top-left corner.
	var rect := create_rect(Color.GRAY)
	grid.add_child(rect)

	# Add column headers.
	var skip = 1 if not mirror else 0
	for header in _elements:
		rect = create_rect(header.main_color)
		grid.add_child(rect)
	
	for rowElement in _elements:
		# Draw row header.
		rect = create_rect(rowElement.main_color)
		grid.add_child(rect)

		var i = 1
		for colElement in _elements:
			var result = ElementManager.get_matchup(rowElement, colElement)
			var color: Color 
			var text := ""

			if i > skip and rowElement != colElement:
				if result == null:
					color = Color.LIGHT_GRAY
				else:
					color = result.main_color
					var vals = ElementManager.get_side_effect(rowElement, colElement)
					var buff = vals[0].name if vals[0] != null else "none"
					var debuff = vals[1].name if vals[1] != null else "none"
					text = "+%s / -%s" % [ buff, debuff ]
			else:
				color = Color.DARK_GRAY

			rect = create_rect(color)
			_matchups[[rowElement, colElement]] = rect
			rect.tooltip_text = text
			grid.add_child(rect)

			i += 1

		if not mirror:
			skip += 1


func create_rect(color := Color.DARK_GRAY) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rect.size_flags_vertical = Control.SIZE_EXPAND_FILL

	return rect


func _on_check_box_toggled(toggledOn: bool) -> void:
	create_grid(toggledOn)


func _on_side_effect_updated(e1: ElementalType, e2: ElementalType) -> void:
	var vals = ElementManager.get_side_effect(e1, e2)
	var text := ""
	var buff = vals[0].name if vals[0] != null else "none"
	var debuff = vals[1].name if vals[1] != null else "none"
	text = "+%s / -%s" % [ buff, debuff ]

	_matchups[[e1, e2]].tooltip_text = text
