@tool
extends Node

enum LogType { BATTLE, PUZZLE }

var battle_logs := []
var puzzle_logs := []

func save_log(type: LogType) -> void:
	var prefix := "res"
	if OS.has_feature("standalone"):
		prefix = "user"

	var path: String
	var output: String
	var logName := Time.get_datetime_string_from_system().replace(":", "_")

	match type:
		LogType.BATTLE:
			path = "%s://logs/battles/%s.txt" % [prefix, logName]
			output = "\n".join(battle_logs)
		LogType.PUZZLE:
			path = "%s://logs/puzzles/%s.txt" % [prefix, logName]
			output = "\n".join(puzzle_logs)

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(output)

func append_log(type: LogType, msg: Variant) -> void:
	if Engine.is_editor_hint(): return
	var logs: Array
	match type:
		LogType.BATTLE:
			logs = battle_logs
		LogType.PUZZLE:
			logs = puzzle_logs
	
	if msg is String:
		logs.append(msg)
	elif msg is Array:
		logs.append_array(msg)
	else:
		logs.append(str(msg))
