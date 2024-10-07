@tool
extends StoryActor

@export var enemy_actor: EnemyActor

# Override
func start_dialog():
	dialog_started.emit(dialog_ids[current_id], enemy_actor)
