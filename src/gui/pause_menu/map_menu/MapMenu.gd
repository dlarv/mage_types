extends Menu

@export var is_map_unlocked := {
	"Legend": true,
	"Hotel": true,
	"Purple": false,
}
var _locked_maps := {}

func _ready() -> void:
	for child in get_children():
		if not is_map_unlocked.has(child.name): continue

		if not is_map_unlocked[child.name]:
			_locked_maps[child.name] = child.duplicate()
			remove_child(child)


func unlock_map(mapName: String) -> void:
	if find_child(mapName): return
	elif not _locked_maps[mapName]: 
		push_warning("Tried to unlock Map(%s), but it could not be found" % mapName)
		Logger.append_world_log("Tried to unhide Map(%s), but it could not be found" % mapName)
		return

	Logger.append_world_log("Map(%s) was unlocked!" % mapName)
	is_map_unlocked[mapName] = true
	add_child(_locked_maps[mapName])
	_locked_maps.erase(mapName)


func serialize() -> Dictionary:
	var data := {}
	for child in get_children():
		# All maps are first/only grandchildren of this node.
		data[child.name] = child.get_child(0).serialize()

	return {
		"path": get_path(),
		"active_maps": is_map_unlocked,
		"data": data
	}


func deserialize(data: Dictionary) -> void:
	is_map_unlocked = data.active_maps
	for child in get_children():
		if child.name in data.data:
			child.get_child(0).deserialize(data.data[child.name])
		else:
			_locked_maps[child.name] = child
			remove_child(child)
