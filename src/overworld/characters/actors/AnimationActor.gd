extends Node3D
class_name AnimationActor

@export var animation_name: String
@export var animation_player: AnimationPlayer
## Prevent player from moving while 
@export var is_blocking := false

func play_animation(player) -> void:
	if is_blocking:
		player.call_deferred("play_cutscene", animation_player, animation_name)
	else:
		animation_player.play(animation_name)
