extends Node3D


@export var dialog_id: String

@onready var story_actor := %StoryActor
var _player: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

	var dialog := Dialog.new()
	dialog.id = dialog_id
	%StoryActor.dialog_ids.append(dialog)


func get_next_dialog_id() -> String:
	return %StoryActor.get_next_dialog_id()


func _on_readable_interacted(obj: Node3D) -> void:
	_player.call_deferred("start_dialog", self)
