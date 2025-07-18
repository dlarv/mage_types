@tool
extends Node

@export var save_threshold_secs := 100
@export var print_logs := false
@export var print_logs_on_save := false
@export var clear_on_save := true

var logs := []

var _root_path: String
var _file_name: String
var _time_til_save := 0.0

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return

	# Check if debug or standalone
	if OS.has_feature("standalone"):
		_root_path = "user://logs/"
		DirAccess.open("user://").make_dir_recursive("logs")
	else:
		_root_path = "res://logs"
		DirAccess.open("res://").make_dir_recursive("logs")
	
	var baseName := Time.get_date_string_from_system().replace(":", "_")

	var root := DirAccess.open(_root_path)
	if not root:
		push_error("Could not open log dir %s" % _root_path)
		return

	# Get game session id
	var files := root.get_files() 
	# 1 indexed bc users might have to find these.
	var id := 1
	while true:
		if "%s__%d.log" % [baseName, id] in files:
			id += 1
		else:
			break
	_file_name = "%s__%d.log" % [baseName, id] 
	FileAccess.open("%s/%s" % [_root_path, _file_name], FileAccess.WRITE)


func _exit_tree() -> void:
	if Engine.is_editor_hint(): return
	save_log()


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_time_til_save += delta
	if _time_til_save > save_threshold_secs:
		save_log()
		_time_til_save = 0


func save_log() -> void:
	if len(logs) == 0: return

	var prefix := "res"
	if OS.has_feature("standalone"):
		prefix = "user"
		#print_logs = false

	var header :="[[WROTE LOG]]@%s" % Time.get_time_string_from_system()
	var path := "%s/%s" % [_root_path, _file_name]
	var output := header + "\n" + "\n".join(logs)
	logs = []

	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if not file: return
	file.seek_end()
	file.store_string(output)

	print(header)
	if print_logs_on_save:
		print(output)
		

func append_log(msg: Variant) -> void:
	if Engine.is_editor_hint(): return
	logs.append(msg)
	if print_logs:
		print(msg)
	

func append_battle_log(msg: Variant) -> void:
	append_log("[BATTLE]@%s --> %s" % [Time.get_time_string_from_system(false), msg])


func append_battle_ai_log(msg: Variant) -> void:
	append_log("[BATTLE AI]@%s --> %s" % [Time.get_time_string_from_system(false), msg])


func append_puzzle_log(msg: Variant) -> void:
	append_log("[PUZZLE]@%s --> %s" % [Time.get_time_string_from_system(false), msg])


func append_world_log(msg: Variant) -> void:
	append_log("[WORLD]@%s --> %s" % [Time.get_time_string_from_system(false), msg])


func append_golem_log(msg: Variant) -> void:
	append_log("[GOLEM]@%s --> %s" % [Time.get_time_string_from_system(false), msg])
