@tool
extends Control

var MatchupItem
var vbox
var save_file = false
var items = {}

func _ready():
	MatchupItem = preload("res://addons/matchupmanager/components/matchup_item.tscn")
	vbox = get_node("VBoxContainer/ScrollContainer/VBoxContainer")

	ElementManager.ForceLoad()
	for matchup in ElementManager.GetAllMatchups():
		var item = MatchupItem.instantiate()
		item.set_colors(matchup[0], matchup[1], matchup[2])
		vbox.add_child(item)

		items[[matchup[0], matchup[1]]] = item

		item.buff_selected.connect(func(index):
			print(index)
			ElementManager.SetSideEffectFor(matchup[0], matchup[1], index, true))
		item.debuff_selected.connect(func(index):
			ElementManager.SetSideEffectFor(matchup[0], matchup[1], index, false))

func _on_save_button_pressed():
	var dialog: FileDialog = get_node("FileDialog")
	dialog.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
	save_file = true
	dialog.show()

func _on_load_button_pressed():
	var dialog: FileDialog = get_node("FileDialog")
	dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
	save_file = false
	dialog.show()


func _on_file_dialog_file_selected(path: String):
	if save_file:
		if(not path.ends_with(".txt") and not path.ends_with(".csv")):
			path += ".csv"

		var data = ElementManager.SaveAsCSV()
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(data)
	else:
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_as_text()
		ElementManager.LoadFromCSV(data)
		for matchup in ElementManager.GetAllMatchups():
			items[[matchup[0], matchup[1]]].set_side_effects(matchup[3], matchup[4])
