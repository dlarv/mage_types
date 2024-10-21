@tool
extends StoryActor
class_name AggressiveStoryActor

@export var enemy_actor: EnemyActor
@export var post_battle_id: int

func _on_battle_ended(playerWasDefeated: bool) -> void:
	if not playerWasDefeated:
		current_id = post_battle_id

func start_dialog():
	dialog_started.emit(dialog_ids[current_id], enemy_actor)
