@tool
extends Menu

const ROOT_PATH := "res://data/beastiary/"

# Array[Array[BattleActor]]
@export var monsters: Array[Array]
@export_tool_button("Regenerate")
var regenerate_button: Callable = func() -> void:
	monsters = []
	for child in %Scroller.get_children(): %Scroller.remove_child(child)
	_traverse(ROOT_PATH)
	_populate_scroller()

var curr_index := 0


func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	regenerate_button.call()


#override
func prev_screen() -> void: 
	curr_index =max(curr_index - 1, 0)
	%InfoDisplay.display_message_non_blocking(monsters[curr_index])


#override
func next_screen() -> void: 
	curr_index = min(curr_index + 1, len(monsters) - 1)
	%InfoDisplay.display_message_non_blocking(monsters[curr_index])


func _traverse(path: String) -> void:
	var root := DirAccess.open(path)

	# Depth first search of files.
	root.list_dir_begin()
	var file := root.get_next()
	while len(file) > 0 and root != null:
		if root.file_exists(file) and file.ends_with(".tscn"):
			_extract(load(path + file).get_state())

		elif root.dir_exists(file):
			_traverse(path + file + "/")

		file = root.get_next()


func _extract(state: SceneState) -> void:
	var id: int
	var actor: BattleActor
	for i in state.get_node_property_count(0):
		match state.get_node_property_name(0, i):
			"monster_id":
				id = state.get_node_property_value(0, i)
			"team":
				var team: Array[BattleActor] = state.get_node_property_value(0, i)
				if len(team) > 0:
					actor = team[0]

	if len(monsters) <= id:
		monsters.resize(id + 1)
	monsters[id].append(actor)
	

func _populate_scroller() -> void:
	for monster in monsters:
		var button := Button.new()
		button.text = monster[0].name
		%Scroller.add_child(button, true)
		button.owner = get_tree().edited_scene_root

		button.pressed.connect(func() -> void: %InfoDisplay.display_message_non_blocking(monster))
