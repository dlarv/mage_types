extends Menu

signal load_button_pressed(fileName: String)

@export var front_end_only := false:
	set(val):
		front_end_only = val
		%LineEdit.visible = not val
		%Save_Button.visible = not val
var _player: Node3D:
	get:
		if _player == null:
			var players = get_tree().get_nodes_in_group("player")
			if len(players) > 0:
				_player = players[0]
		return _player
var saved_games := []
var _freed_objs := []

func _ready() -> void:
	setup()

func setup() -> void:
	var root := DirAccess.open("user://")
	root.make_dir_recursive("games")

	var group := ButtonGroup.new()
	var dir := DirAccess.open(Settings.SAVE_ROOT_DIR)
	if dir:
		saved_games = dir.get_files()
		for file in saved_games:
			var button := Button.new()
			button.text = file
			button.button_group = group
			button.pressed.connect(func():
				%LineEdit.text = file
				%Delete_Button.disabled = false)
			%SavedGamesScroller.add_child(button)
	
	var objs := get_tree().get_nodes_in_group("persist")
	for obj in objs:
		obj.tree_exiting.connect(func():
			_freed_objs.append(obj.get_path()))

	if Settings.loaded_save_data:
		read_file(Settings.loaded_save_data)
		Settings.loaded_save_data = null


func save() -> void:
	var fileName = %LineEdit.text
	var path := "%s/%s" % [ Settings.SAVE_ROOT_DIR, fileName ]
	if not fileName in saved_games:
		var button := Button.new()
		button.text = fileName
		button.pressed.connect(func():
			%LineEdit.text = fileName)
		%SavedGamesScroller.add_child(button)

	var objs := get_tree().get_nodes_in_group("persist")
	var file := FileAccess.open(path, FileAccess.WRITE)

	# Store info that does not rely on main scene being loaded.
	file.store_var({"player_name": _player.player_name})
	file.store_var(_freed_objs)

	for obj in objs:
		if obj.has_method("serialize"):
			file.store_var(obj.serialize())
		else:
			push_warning("Tried to serialize %s, but class has no serialize method." % obj.get_path())

	print("Saved game")
	file.close()

func load() -> void:
	if front_end_only:
		load_button_pressed.emit(%LineEdit.text)
		return
	var fileName = %LineEdit.text
	var path := "%s/%s" % [ Settings.SAVE_ROOT_DIR, fileName ]
	var file := FileAccess.open(path, FileAccess.READ)

	# Information that must be accessed by home page before main scene is instantiated is saved at the beginning
	# of the file inside a dictionary.
	var data = file.get_var()
	if data.has("player_name"):
		Settings.set_player_name(data["player_name"])
		print("Set player name to %s" % data["player_name"])

	# Read rest of data.
	read_file(file)
	print("Loaded game from %s" % path)
	file.close()

func read_file(file: FileAccess) -> void:
	while file.get_position() < file.get_length():
		var obj = file.get_var()
		if obj is Dictionary:
			var node = get_node(obj.get("path"))
			if node.has_method("deserialize"):
				node.deserialize(obj)
			else:
				push_warning("Tried to deserialize %s, but class has no deserialize method." % obj.get("path"))
		elif obj is Array:
			_freed_objs = obj
			for o in _freed_objs:
				var node = get_node(o)
				if node:
					node.queue_free()


func _on_visibility_changed() -> void:
	if not visible or not _player: return
	%LineEdit.text = _player.player_name

func _on_delete_button_pressed() -> void:
	var fileName = %LineEdit.text
	if not fileName in saved_games: return

	var index := saved_games.find(fileName)
	saved_games.remove_at(index)

	DirAccess.remove_absolute("%s/%s" % [ Settings.SAVE_ROOT_DIR, fileName ])

	for child in %SavedGamesScroller.get_children():
		if child.text == fileName:
			%SavedGamesScroller.remove_child(child)
			return
