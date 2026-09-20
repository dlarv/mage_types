extends Node3D

signal finished()

const BattleSprite := preload("res://src/battle_system/gui/battle_sprite/BattleSprite.gd")
const Controller := preload("res://src/battle_system/gui/battle_sprite/BattleActorController.gd")
const DURATION := 3.0

var _sprites: Dictionary[BattleActor, BattleSprite] = {}

func animate(turnData: ActorTurnData, missed: bool) -> void:
	# Play user.channeling & channeling particle effect
	var userSprite :=_sprites[turnData.user]
	var userController := userSprite.get_controller()

	userSprite.set_action_text(turnData.action)

	await _animate_channeling(userController, turnData.action.calculate_affinity(turnData.user))

	if missed:
		finished.emit()
		return

	# Play attack animation in the latter half of the user's animation
	turnData.action.play_animation(
		userSprite.get_target_position(), 
		_sprites[turnData.targets[0]].get_target_position(), 
		self
	)

	# Play animation for each target getting hit
	await _animate_impacts(turnData.targets)
	await _animate_defeats(turnData.get_defeated())

	# Calculate melee transmutations
	await animate_transmutations(userController)

	finished.emit()


func _on_battle_sprite_added(actor: BattleActor, sprite: BattleSprite) -> void:
	_sprites[actor] = sprite


func animate_transmutations(obj: Variant) -> void:
	var controller: Controller = _sprites[obj].get_controller() if obj is BattleActor else obj
	await controller.animate_transmutations()


func _animate_channeling(controller: Controller, strength: float) -> void:
	controller.start_channeling_particles(DURATION, strength)
	controller.play_animation("channeling")
	await controller.channeling_finished
	

func _animate_defeats(actors: Array[BattleActor]) -> void:
	var last: Controller
	for actor in actors:
		last = _sprites[actor].get_controller()
		last.play_animation("defeated")

	#if last and last.has_animation("defeated"):
		#await last.defeated_finished	
	await get_tree().create_timer(0.2).timeout


func _animate_impacts(targets: Array[BattleActor]) -> void: 
	for actor in targets:
		var controller := _sprites[actor].get_controller()
		controller.play_animation("getting_hit")
		await animate_transmutations(controller)

	get_tree().call_group("hp_display", "animate_hp")
