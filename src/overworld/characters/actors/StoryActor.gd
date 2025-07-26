@tool
extends Node3D
class_name StoryActor
## Allows a character to participate in the game's story, mostly through dialog.

signal dialog_started(dialog_id: String, data: Variant)

@export var dialog_ids: Array[Dialog]
@export var current_id: int = 0
@export var animation_player: AnimationPlayer

var _prev_id := current_id

func _ready() -> void:
	if not animation_player:
		animation_player = find_child("AnimationPlayer")


func start_dialog() -> void:
	dialog_started.emit(dialog_ids[current_id], null)


func skip_dialog() -> void:
	var dialog := dialog_ids[_prev_id]
	if len(dialog.end_state) > 0:
		var animation := animation_player.get_animation(dialog.end_state)
		animation_player.play(dialog.end_state)
		animation_player.advance(animation.length)
	elif animation_player and animation_player.is_playing():
		var animation := animation_player.get_animation(animation_player.current_animation)
		animation_player.advance(animation.length)


func play_cutscene(id: String) -> void:
	if not animation_player: 
		push_warning("No animation player attached to this StoryActor(%s)")
		return
	animation_player.play(id)
	await animation_player.animation_finished

func get_next_dialog_id() -> String:
	if len(dialog_ids) == 0: return ""
	var output := dialog_ids[current_id]
	if output.next >= 0:
		_prev_id = current_id
		current_id = output.next
	return output.id
