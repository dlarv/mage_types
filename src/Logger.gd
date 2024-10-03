extends Node

enum LogType { BATTLE }

var battle_logs = []

func save_log(type: LogType):
	var path: String
	var output: String
	var logName = Time.get_datetime_string_from_system().replace(":", "_")

	match type:
		LogType.BATTLE:
			path = "res://logs/battles/%s.txt" % logName
			output = "\n".join(battle_logs)

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(output)

func append_log(type: LogType, msg):
	var logs: Array
	match type:
		LogType.BATTLE:
			logs = battle_logs
	
	if msg is String:
		logs.append(msg)
	elif msg is Array:
		logs.append_array(msg)
	else:
		logs.append(str(msg))
