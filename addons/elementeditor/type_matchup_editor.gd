@tool
extends Control

var vbox: VBoxContainer
var elements = []
var file_dialog: FileDialog

func _ready():
	vbox = find_child("VBoxContainer", true)
	file_dialog = find_child("FileDialog", true)
	
	var headers = vbox.get_child(1)
	for header in headers.get_children():
		var name = header.name
		if not name.contains("Header_"): continue
		name = name.trim_prefix("Header_")
		var element = ElementalType.new(name.capitalize(), header.color)
		elements.append(element)
		MatchupManager.add_element(element)
		
	var row_index = 0
	for row in vbox.get_children().slice(2):
		var col_index = -1
		for child in row.get_children():
			if child is ColorRect: continue
			col_index += 1
			
			if col_index <= row_index:
				child.set_disabled(true)
				continue
				
			child.update(elements)
			child.item_selected.connect(_on_matchup_selected)
			child.set_coord(row_index, col_index)
		row_index += 1

	_on_load_button_pressed("res://elemental_system/matchup_data_files/default.txt")

func _on_matchup_selected(row: int, col: int, element: int, effect: int, mod: int):
	var element1 = elements[row]
	var element2 = elements[col]
	var element3 = null
	if element > -1:
		element3 = elements[element]
	
	MatchupManager.add_matchup(element1, element2, element3, effect, mod)


func _on_save_button_pressed():
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.show()
	var path = await file_dialog.file_selected
	MatchupManager.write_to_file(path)


func _on_load_button_pressed(path=null):
	if path == null:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.show()
		path = await file_dialog.file_selected

	MatchupManager.load_from_file(path)
	
	var row_index = 0
	for row in vbox.get_children().slice(2):
		var col_index = -1
		for child in row.get_children():
			if child is ColorRect: continue
			
			col_index += 1
			if child.is_disabled(): 
				continue
			
			var e1 = elements[row_index]
			var e2 = elements[col_index]
			var res = MatchupManager.get_matchup(e1, e2)
			child.set_matchup(res)
			
		row_index += 1

func _on_clear_button_pressed():
	MatchupManager.matchups = {}
	for row in vbox.get_children().slice(2):
		for child in row.get_children():
			if child is ColorRect: continue
			if child.is_disabled(): continue
			child.set_matchup(null)


