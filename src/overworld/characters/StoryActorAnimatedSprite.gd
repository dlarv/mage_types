@tool
extends AnimatedTexture
class_name StoryActorAnimatedTexture

@export var order: Array[String]
@export var _current_frame: int:
	set(val):
		current_frame = val
	get:
		return current_frame

func set_emotion(key: String) -> void:
	var index := order.find(key)
	if index != -1:
		current_frame = index

