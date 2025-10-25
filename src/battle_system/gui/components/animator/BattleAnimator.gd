extends Node3D

signal finished()

const BattleSprite := preload("res://src/battle_system/gui/components/animator/BattleSprite.gd")

var _sprites: Dictionary[BattleActor, BattleSprite] = {}


func animate(turnData: ActorTurnData, missed: bool) -> void:
	# Play user.channeling & channeling particle effect
	const DURATION := 3.0
	var userSprite := _sprites[turnData.user]
	var affinity: float = turnData.action.calculate_affinity(turnData.user)
	if affinity <= Attack.POOR_AFFINITY_THRESHOLD:
		userSprite.show_elemental_particles(turnData.action.element, DURATION, 5)
	elif affinity <= Attack.WEAK_AFFINITY_THRESHOLD:
		userSprite.show_elemental_particles(turnData.action.element, DURATION, 20)
	elif affinity <= Attack.GOOD_AFFINITY_THRESHOLD:
		userSprite.show_elemental_particles(turnData.action.element, DURATION, 50)
	else:
		userSprite.show_elemental_particles(turnData.action.element, DURATION, 80)

	await userSprite.play_animation("channeling")

	# Play user.attack, attack animation, then targets.getting_hit
	var userPosition: Vector2 = userSprite.get_target_position()
	var targetPosition: Vector2 = _sprites[turnData.targets[0]].get_target_position()
	var attackDuration := userSprite.get_animation_duration("attack")
	userSprite.play_animation("attack")

	if missed:
		finished.emit()
		return

	# Play attack animation in the latter half of the user's animation
	await get_tree().create_timer(attackDuration / 2).timeout
	turnData.action.play_animation(userPosition, targetPosition, self)
	await get_tree().create_timer(attackDuration / 2).timeout

	# Play animation for each target getting hit
	for actor in turnData.targets:
		_sprites[actor].play_animation("getting_hit")

	finished.emit()


func _on_battle_sprite_added(actor: BattleActor, sprite: BattleSprite) -> void:
	_sprites[actor] = sprite
