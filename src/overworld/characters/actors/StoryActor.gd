@tool
extends Node3D
class_name StoryActor
## Allows a character to participate in the game's story, mostly through dialog .

signal dialog_started(dialog_id, data)

@export var dialog_ids: Array[String]
@export var current_id: int = 0

# Virtual
func start_dialog():
	print("HERE")
	dialog_started.emit(dialog_ids[current_id], null)

