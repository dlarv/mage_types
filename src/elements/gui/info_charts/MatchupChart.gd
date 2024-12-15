@tool
extends Control


@export var grid: GridContainer
@export var reload: bool:
	set(value):
		create_grid()

var MatchupCell := preload("./MatchupCell.gd")

var _elements := []
var _matchups := {}

## If true, focus on the cell hovered over by player.
var do_highlighting := true

func _ready():
	if grid == null: return

	ElementManager.force_load()
	_elements = ElementManager.elements

	create_grid()


func create_grid(mirror:=false) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
	
	# Add empty spacer to top-left corner.
	var rect := MatchupCell.new(Color.GRAY)
	grid.add_child(rect)

	# Add column headers.
	var headers := []
	for header in _elements:
		rect = MatchupCell.new(header.main_color)
		rect.mouse_entered.connect(func():
			if not do_highlighting: return
			for child in grid.get_children():
				child.focus(true))
		grid.add_child(rect)
		headers.append(rect)
	
	var skip = 1 if not mirror else 0
	for rowElement in _elements:
		var rowHeader :=  MatchupCell.new(rowElement.main_color)
		rowHeader.mouse_entered.connect(func():
			if not do_highlighting: return
			for child in grid.get_children():
				child.focus(true))
		grid.add_child(rowHeader)

		var i = 1
		for colElement in _elements:
			var result = ElementManager.get_matchup(rowElement, colElement)
			var resist := ElementManager.get_resistance(colElement, rowElement)
			var color: Color 
			var text := []

			if result == null:
				color = MatchupCell.ALT_GRAY
			else:
				color = result.main_color
				var buff = ElementManager.get_side_effect(rowElement, colElement)[0].name
				text.append("+%s" % buff)

			var isHidden: bool = i <= skip

			if resist > 1:
				text.append("%s resists %s" % [ colElement.name, rowElement.name])
			elif resist < 1:
				text.append("%s beats %s" % [ rowElement.name, colElement.name])

			rect = MatchupCell.new(color, resist, isHidden)
			_matchups[[rowElement, colElement]] = rect
			rect.tooltip_text = "\n".join(text)	
			grid.add_child(rect)

			# Call focus on this cell and its related headers.
			# Call unfocus on every other cell.
			rect.set_headers(headers[i - 1], rowHeader)
			rect.mouse_entered.connect(_on_new_cell_focused.bind(rect))

			i += 1

		if not mirror:
			skip += 1

func _on_check_box_toggled(toggledOn: bool) -> void:
	for cell in grid.get_children():
		cell.reveal(toggledOn)


func _on_side_effect_updated(e1: ElementalType, e2: ElementalType) -> void:
	var vals = ElementManager.get_side_effect(e1, e2)
	var text := ""
	var buff = vals[0].name if vals[0] != null else "none"
	var debuff = vals[1].name if vals[1] != null else "none"
	text = "+%s / -%s" % [ buff, debuff ]

	_matchups[[e1, e2]].tooltip_text = text

func _on_new_cell_focused(cell: ColorRect) -> void:
	if not do_highlighting: return

	for rect in grid.get_children():
		rect.focus(rect == cell)
	cell.focus(true)
	cell.reveal(true)


func _on_highlight_checkbox_toggled(toggledOn:bool) -> void:
	do_highlighting = toggledOn

	for child in grid.get_children():
		child.focus(true)

