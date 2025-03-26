extends Menu

const SAVE_ROOT_DIR := "user://games"

var _player: Node3D
var _saved_games := []
var _freed_objs := []

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if len(players) > 0:
		_player = players[0]
	else:
		return

	var root := DirAccess.open("user://")
	root.make_dir_recursive("games")

	var group := ButtonGroup.new()
	var dir := DirAccess.open(SAVE_ROOT_DIR)
	if dir:
		_saved_games = dir.get_files()
		for file in _saved_games:
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

func save() -> void:
	var fileName = %LineEdit.text
	var path := "%s/%s" % [ SAVE_ROOT_DIR, fileName ]
	if not fileName in _saved_games:
		var button := Button.new()
		button.text = fileName
		button.pressed.connect(func():
			%LineEdit.text = fileName)
		%SavedGamesScroller.add_child(button)

	var objs := get_tree().get_nodes_in_group("persist")
	var file := FileAccess.open(path, FileAccess.WRITE)

	file.store_var(_freed_objs)
	file.store_var(_player.player_name)

	for obj in objs:
		if obj.has_method("serialize"):
			file.store_var(obj.serialize())
		else:
			push_warning("Tried to serialize %s, but class has no serialize method." % obj.get_path())

	print("Saved game")
	file.close()

func load() -> void:
	var fileName = %LineEdit.text
	var path := "%s/%s" % [ SAVE_ROOT_DIR, fileName ]
	var file := FileAccess.open(path, FileAccess.READ)

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
		elif obj is String:
			Settings.set_player_name(obj)
			print("Set player name to %s" % obj)

	print("Loaded game from %s" % path)
	file.close()

func _on_visibility_changed() -> void:
	if not visible: return
	%LineEdit.text = _player.player_name

func _on_delete_button_pressed() -> void:
	var fileName = %LineEdit.text
	if not fileName in _saved_games: return

	var index := _saved_games.find(fileName)
	_saved_games.remove_at(index)

	DirAccess.remove_absolute("%s/%s" % [ SAVE_ROOT_DIR, fileName ])

	for child in %SavedGamesScroller.get_children():
		if child.text == fileName:
			%SavedGamesScroller.remove_child(child)
			return
