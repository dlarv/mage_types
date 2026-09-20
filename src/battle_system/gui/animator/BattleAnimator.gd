extends Node3D

signal finished()

const BattleSprite := preload("res://src/battle_system/gui/battle_sprite/BattleSprite.gd")
const Controller := preload("res://src/battle_system/gui/battle_sprite/BattleActorController.gd")
const BLOCK := preload("res://data/battle_system/status_effects/blocking_effect.tres")
const DURATION := 3.0

var _sprites: Dictionary[BattleActor, BattleSprite] = {}


func animate(turnData: ActorTurnData, missed: bool) -> void:
	# Play user.channeling & channeling particle effect
	var userSprite :=_sprites[turnData.user]
	var userController := userSprite.get_controller()

	var affinity: float = turnData.action.calculate_affinity(turnData.user)
	userController.start_channeling_particles(DURATION, affinity)

	userSprite.set_action_text(turnData.action)

	userController.play_animation("channeling")
	await userController.channeling_finished

	# Play user.attack, attack animation, then targets.getting_hit
	var userPosition: Vector2 = userSprite.get_target_position()
	var targetPosition: Vector2 = _sprites[turnData.targets[0]].get_target_position()

	if missed:
		finished.emit()
		return

	# Play attack animation in the latter half of the user's animation
	turnData.action.play_animation(userPosition, targetPosition, self)

	# Play animation for each target getting hit
	for actor in turnData.targets:
		_sprites[actor].get_controller().play_animation("getting_hit")

	get_tree().call_group("hp_display", "animate_hp")

	# Animate any defeated characters
	var last: Controller
	for actor in turnData.get_defeated():
		last = _sprites[actor].get_controller()
		last.play_animation("defeated")

	#if last and last.has_animation("defeated"):
		#await last.defeated_finished	
	await get_tree().create_timer(0.2).timeout
	finished.emit()


func _on_battle_sprite_added(actor: BattleActor, sprite: BattleSprite) -> void:
	_sprites[actor] = sprite
