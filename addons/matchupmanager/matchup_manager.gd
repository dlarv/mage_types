@tool
extends Control
#
# @export var vbox: VBoxContainer
# @export var tab_container: TabContainer
# @export var chart: Control
#
# var MatchupItem
# var save_file = false
# var items = {}
#
# func _ready():
# 	MatchupItem = preload("res://addons/matchupmanager/components/matchup_item.tscn")
# 	# vbox = get_node("TabContainer/VBoxContainer/ScrollContainer/VBoxContainer")
#
# 	ElementManager.force_load()
# 	return
# 	for matchup in ElementManager.get_all_matchups():
# 		var item = MatchupItem.instantiate()
# 		item.set_colors(matchup[0], matchup[1], matchup[2])
# 		vbox.add_child(item)
#
# 		items[[matchup[0], matchup[1]]] = item
#
# 		# item.buff_selected.connect(func(index):
# 		# 	ElementManager.set_side_effect_for(matchup[0], matchup[1], index, true))
# 		# item.debuff_selected.connect(func(index):
# 		# 	ElementManager.set_side_effect_for(matchup[0], matchup[1], index, false))
# 	
# 	# ElementManager.side_effects_updated.connect(chart._on_side_effect_updated)
# 	if Engine.is_editor_hint():
# 		tab_container.current_tab = 1
# 	else:
# 		tab_container.current_tab = 0
#
# func _on_save_button_pressed():
# 	var dialog: FileDialog = get_node("FileDialog")
# 	dialog.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
# 	save_file = true
# 	dialog.show()
#
# func _on_load_button_pressed():
# 	var dialog: FileDialog = get_node("FileDialog")
# 	dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
# 	save_file = false
# 	dialog.show()
#
#
# func _on_file_dialog_file_selected(path: String):
# 	if save_file:
# 		if(not path.ends_with(".txt") and not path.ends_with(".csv")):
# 			path += ".csv"
#
# 		var data = ElementManager.save_as_csv()
# 		var file = FileAccess.open(path, FileAccess.WRITE)
# 		file.store_string(data)
# 	else:
# 		var file = FileAccess.open(path, FileAccess.READ)
# 		var data = file.get_as_text()
# 		ElementManager.load_from_csv(data)
# 		for matchup in ElementManager.get_all_matchups():
# 			items[[matchup[0], matchup[1]]].set_side_effects(matchup[3], matchup[4])
