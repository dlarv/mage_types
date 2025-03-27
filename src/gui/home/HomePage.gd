extends PanelContainer

func _ready() -> void:
	$MarginContainer/Version_Label.text = "v" + ProjectSettings.get_setting("application/config/version")
	$MarginContainer/Title.text = ProjectSettings.get_setting("application/config/name")


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
	open("Player")

