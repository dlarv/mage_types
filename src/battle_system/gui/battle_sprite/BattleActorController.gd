extends Node

signal helper_text_requested(msg: String, duration: float)
signal channeling_finished
signal defeated_finished

const BattleActorDisplay := preload("res://src/battle_system/gui/components/BattleActorDisplay.gd")

const EQUIPMENT_TEXT_DURATION := 0.8
const ENEMY_MODEL_ROTATION := 180.0

@export var flip_model_if_enemy := false
@export var pre_transmutation_delay := 0.4
@export var inter_transmutation_delay := 0.8
@export var post_transmutation_delay := 0.1

var actor: BattleActor

var _animation_state: AnimationNodeStateMachinePlayback
var _is_defeated := false
var _element_queue: Array[ElementalType] = []


func setup(actor: BattleActor, display: BattleActorDisplay, isEnemy: bool) -> void:
	self.actor = actor
	_element_queue = []
	
	$AnimationTree.active = true
	_animation_state = $AnimationTree["parameters/playback"]
	_animation_state.state_finished.connect(_on_state_finished)

	if not actor.equipment_activated.is_connected(_on_equipment_activated):
		actor.equipment_activated.connect(_on_equipment_activated)

	_is_defeated = false
	%EmitterController.is_ally = not isEnemy

	$MeshManager.setup(actor)

	$PinManager.status_manager = actor.statuses

	actor.status_effect_added.connect(_append_new_status_effect)
	actor.status_effects_removed.connect(_append_remove_status_effect)
	actor.was_just_defeated.connect(_on_actor_defeated) 
	actor.action_selected.connect(_on_action_selected)
	actor.status_activated.connect(_append_status_activation)
	actor.element_changed.connect(_append_transmutation)

	# Battle.transmutations_started.connect(_on_transmutation_phase.bind(true))
	# Battle.transmutations_finished.connect(_on_transmutation_phase.bind(false))

	if isEnemy and flip_model_if_enemy:
		$PinManager.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$PinManager/PhobiaCrown.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$MeshManager.mesh.rotation_degrees.y += ENEMY_MODEL_ROTATION


func _exit_tree() -> void:
	if self.actor.equipment_activated.is_connected(_on_equipment_activated):
		self.actor.equipment_activated.disconnect(_on_equipment_activated)

	actor.status_effect_added.disconnect(_append_new_status_effect)
	actor.status_effects_removed.disconnect(_append_remove_status_effect)
	actor.was_just_defeated.disconnect(_on_actor_defeated) 
	actor.action_selected.disconnect(_on_action_selected)
	actor.status_activated.disconnect(_append_status_activation)

	# Battle.transmutations_started.disconnect(_on_transmutation_phase.bind(true))
	# Battle.transmutations_finished.disconnect(_on_transmutation_phase.bind(false))


func play_intro() -> void:
	$MeshManager.play_intro()
	play_animation("battle_entry")


func play_animation(name: String) -> void:
	_animation_state.travel(name)
	await _animation_state.state_finished


func _on_state_finished(stateName: String) -> void:
	match stateName:
		"channeling":
			channeling_finished.emit()
		"defeated":
			defeated_finished.emit()


func has_animation(n: String) -> bool:
	return $AnimationTree.has_animation(n)


func start_channeling_particles(duration: float, strength: float) -> void:
	%EmitterController.play_channeling(duration, strength)


func animate_transmutations() -> void:
	if len(_element_queue) == 0: return

	$MeshManager.fade_aura(true)
	await get_tree().create_timer(pre_transmutation_delay).timeout

	for element in _element_queue:
		$MeshManager.set_element(1, element)
		await get_tree().create_timer(inter_transmutation_delay).timeout
	_element_queue = []

	await get_tree().create_timer(post_transmutation_delay).timeout
	await $MeshManager.fade_aura(false)



func _append_new_status_effect(effect: StatusEffect) -> void: 
	$PinManager.insert_pin(effect)


func _append_remove_status_effect(effects: Array[StatusEffect]) -> void: 
	$PinManager.remove_pins(effects)


func _append_status_activation(effect: StatusEffect, data:Variant=null) -> void:
	$PinManager.activate_pin(effect)
	helper_text_requested.emit(effect.name, ProjectSettings.get_setting("custom/general/helper_text_interval"))


func _on_transmutation_phase(a: BattleActor, started: bool) -> void:
	if a != actor: return
	# $MeshManager.fade_aura(started)
	pass


func _on_equipment_activated(equipment: Equipment) -> void:
	helper_text_requested.emit(equipment.name, EQUIPMENT_TEXT_DURATION)


func _on_actor_defeated() -> void:
	$PinManager.hide_pins.call()
	$MeshManager.set_defeated()
	_is_defeated = true


func _on_action_selected(action: _BattleAction) -> void:
	%EmitterController.set_action_element(action.element)


func _append_transmutation(id: int, element: ElementalType) -> void:
	_element_queue.append(element)
