@tool
extends Node3D
class_name StoryActor
## Allows a character to participate in the game's story, mostly through dialog.

signal dialog_started(dialog_id, data)

@export var dialog_ids: Array[Dialog]
@export var current_id: int = 0
@export var character: Character

# Virtual
func start_dialog():
	dialog_started.emit(dialog_ids[current_id], null)


func play_cutscene(id: String) -> void:
	if not $AnimationPlayer: 
		push_warning("No animation player attached to this StoryActor(%s)")
		return
	$AnimationPlayer.play(id)
	await $AnimationPlayer.animation_finished


func change_emotion(id:="NEUTRAL") -> void:
	if not character: return
	if character.image is StoryActorAnimatedTexture:
		character.image.set_emotion(id)


func get_next_dialog_id() -> String:
	var output := dialog_ids[current_id]
	if output.next >= 0:
		current_id = output.next
	return output.id
