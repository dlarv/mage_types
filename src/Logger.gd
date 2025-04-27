@tool
extends Node

enum LogType { BATTLE, PUZZLE, WORLD }

@export var print_logs := true
@export var print_logs_on_save := true
@export var clear_on_save := true

var battle_logs := []
var puzzle_logs := []
var world_logs := []

func save_log(type: LogType) -> void:
	var prefix := "res"
	if OS.has_feature("standalone"):
		prefix = "user"

	var path: String
	var output: String
	var logName := Time.get_datetime_string_from_system().replace(":", "_")
	var logs: Array

	match type:
		LogType.BATTLE:
			path = "%s://logs/battles/%s.txt" % [prefix, logName]
			output = "\n".join(battle_logs)
			logs = battle_logs
			if clear_on_save:
				battle_logs = []
		LogType.PUZZLE:
			path = "%s://logs/puzzles/%s.txt" % [prefix, logName]
			output = "\n".join(puzzle_logs)
			logs = puzzle_logs
			if clear_on_save:
				puzzle_logs = []
		LogType.WORLD:
			path = "%s://logs/world/%s.txt" % [prefix, logName]
			output = "\n".join(world_logs)
			logs = world_logs
			if clear_on_save:
				world_logs = []

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(output)

	if print_logs_on_save:
		print(output)
		

func append_log(type: LogType, msg: Variant) -> void:
	if Engine.is_editor_hint(): return
	var logs: Array
	match type:
		LogType.BATTLE:
			logs = battle_logs
		LogType.PUZZLE:
			logs = puzzle_logs
		LogType.WORLD:
			logs = world_logs
	
	if msg is String:
		logs.append(msg)
	elif msg is Array:
		logs.append_array(msg)
	else:
		logs.append(str(msg))
	
	if print_logs:
		print(msg)
	

func append_battle_log(msg: Variant) -> void:
	append_log(LogType.BATTLE, msg)


func append_puzzle_log(msg: Variant) -> void:
	append_log(LogType.PUZZLE, msg)


func append_world_log(msg: Variant) -> void:
	append_log(LogType.WORLD, msg)
