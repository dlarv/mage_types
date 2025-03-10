extends Node

@export var vars := {}

var dialog_box: DialogueBox

func _ready() -> void:
	var root := get_tree().get_current_scene()
	dialog_box = root.get_node("%DialogueBox")

func set_story_var(key: String, value: Variant) -> void:
	if not vars.has(key):
		push_warning("No story event with Key(%s) exists.")
		return
	vars[key] = value

func get_story_var(key: String) -> Variant:
	if not vars.has(key):
		push_warning("No story event with Key(%s) exists.")
		return null
	return vars[key]


func play_cutscene(key: String) -> void:
	pass
