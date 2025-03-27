extends PanelContainer

func _ready() -> void:
	%Version_Label.text = "v" + ProjectSettings.get_setting("application/config/version")
	%Title.text = ProjectSettings.get_setting("application/config/name")


func open(fileName: String) -> void:
	# Load settings like the seed before opening scene.
	var path := "%s/%s" % [ Settings.SAVE_ROOT_DIR, fileName ]
	var file := FileAccess.open(path, FileAccess.READ)

	# Information that must be accessed by home page before main scene is instantiated is saved at the beginning
	# of the file inside a dictionary.
	var data = file.get_var()
	if data.has("player_name"):
		Settings.set_player_name(data["player_name"])
		print("Set player name to %s" % data["player_name"])

	Settings.loaded_save_data = file
	get_tree().change_scene_to_file("res://world/demo.tscn")


func _on_load_game_button_pressed() -> void:
	%SaveMenu.show()
	%Back_Button.show()


func _on_continue_button_pressed() -> void:
	var savedGames: Array = %SaveMenu.saved_games
	if len(savedGames) == 0:
		%NewGame.show()
		return

	var path: String

	var maxTime := -1
	var maxPath: String
	for game in %SaveMenu.saved_games:
		var time := FileAccess.get_modified_time("%s/%s" % [Settings.SAVE_ROOT_DIR, game])
		if time > maxTime:
			maxPath = game
			maxTime = time

	open(maxPath)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	%SettinsMenu.show()
	%Back_Button.show()


func _on_new_game_button_pressed() -> void:
	%NewGame.show()
	%Back_Button.show()


func _on_back_button_pressed() -> void:
	%TabContainer.current_tab = 0
	%Back_Button.hide()


func _on_save_menu_load_button_pressed(fileName:String) -> void:
	open(fileName)



