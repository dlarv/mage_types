extends Node3D
class_name AnimationActor

@export var animation_name: String
@export var animation_player: AnimationPlayer
## Prevent player from moving while animation is playing.
@export var is_blocking := false

func play_animation(player) -> void:
	print("AnimationActor played %s cutscene." % animation_name)
	Logger.append_log(Logger.LogType.PUZZLE, "AnimationActor played %s cutscene." % animation_name)
	if is_blocking:
		player.call_deferred("play_cutscene", animation_player, animation_name)
	else:
		animation_player.play(animation_name)
