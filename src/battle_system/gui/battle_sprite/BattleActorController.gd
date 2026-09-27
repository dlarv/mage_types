extends Node

signal helper_text_requested(msg: String, duration: float)
signal channeling_finished
signal defeated_finished

const BattleActorDisplay := preload("res://src/battle_system/gui/components/BattleActorDisplay.gd")

const EQUIPMENT_TEXT_DURATION := 0.8
const ENEMY_MODEL_ROTATION := 180.0
const GETTING_HIT_SFX: AudioStream = null
const CHANNELING_SFX: AudioStream = null

@export var flip_model_if_enemy := false
@export var pre_transmutation_delay := 0.4
@export var inter_transmutation_delay := 0.8
@export var post_transmutation_delay := 0.1
@export var post_status_insertion_delay := 0.5

var actor: BattleActor

var _animation_state: AnimationNodeStateMachinePlayback
var _is_defeated := false
var _element_queue: Array[ElementalType] = []
var _activated_status_queue: Array[StatusEffect]
var _expired_status_queue: Array[StatusEffect]
var _new_status_queue: Array[StatusEffect]


func setup(actor: BattleActor, display: BattleActorDisplay, isEnemy: bool) -> void:
	self.actor = actor
	_element_queue = []
	
	$AnimationTree.active = true
	_animation_state = $AnimationTree["parameters/playback"]
	_animation_state.state_finished.connect(_on_state_finished)
	_animation_state.state_started.connect(_on_state_started)

	if not actor.equipment_activated.is_connected(_on_equipment_activated):
		actor.equipment_activated.connect(_on_equipment_activated)

	_is_defeated = false
	%EmitterController.is_ally = not isEnemy

	$MeshManager.setup(actor)

	$PinManager.status_manager = actor.statuses

	actor.status_effect_added.connect(_append_new_status_effect)
	actor.status_effects_removed.connect(_append_expired_status_effect)
	actor.was_just_defeated.connect(_on_actor_defeated) 
	actor.action_selected.connect(_on_action_selected)
	actor.status_activated.connect(_append_status_activation)
	actor.element_changed.connect(_append_transmutation)

	if isEnemy and flip_model_if_enemy:
		$PinManager.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$PinManager/PhobiaCrown.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$MeshManager.mesh.rotation_degrees.y += ENEMY_MODEL_ROTATION


func _exit_tree() -> void:
	if self.actor.equipment_activated.is_connected(_on_equipment_activated):
		self.actor.equipment_activated.disconnect(_on_equipment_activated)

	actor.status_effect_added.disconnect(_append_new_status_effect)
	actor.status_effects_removed.disconnect(_append_expired_status_effect)
	actor.was_just_defeated.disconnect(_on_actor_defeated) 
	actor.action_selected.disconnect(_on_action_selected)
	actor.status_activated.disconnect(_append_status_activation)


func play_intro() -> void:
	$MeshManager.play_intro()
	play_animation("battle_entry")


func play_animation(name: String) -> void:
	if name == "getting_hit":
		if animate_status_activation(StatusEffect.Effects.BLOCK): 
			await get_tree().create_timer(post_status_insertion_delay).timeout
			return

		for status in _new_status_queue:
			$PinManager.insert_pin(status)
		_new_status_queue = []
		await get_tree().create_timer(post_status_insertion_delay).timeout

	_animation_state.travel(name)
	# _animation_state.state_finished


func _on_state_finished(stateName: String) -> void:
	match stateName:
		"channeling":
			channeling_finished.emit()
		"defeated":
			defeated_finished.emit()


func _on_state_started(stateName: String) -> void:
	pass


func has_animation(n: String) -> bool:
	return $AnimationTree.has_animation(n)


func start_channeling_particles(duration: float, strength: float) -> void:
	%EmitterController.play_channeling(duration, strength)


func animate_transmutations() -> void:
	if len(_element_queue) == 0: return
	elif animate_status_activation(StatusEffect.Effects.STASIS): return

	$MeshManager.fade_aura(true)
	await get_tree().create_timer(pre_transmutation_delay).timeout

	for element in _element_queue:
		$MeshManager.set_element(1, element)
		# TODO: Activate Phobia iff it is same element
		animate_phobia_activation(element)
		await get_tree().create_timer(inter_transmutation_delay).timeout
	_element_queue = []

	await get_tree().create_timer(post_transmutation_delay).timeout
	await $MeshManager.fade_aura(false)


func remove_status(effects: Array[StatusEffect]) -> void:
	$PinManager.remove_pins(effects)


## If status activated during the turn, animate it and remove it from queue
func animate_status_activation(id: StatusEffect.Effects) -> bool:
	var i := -1
	for status in _activated_status_queue:
		i += 1
		if status.id == id:
			_activated_status_queue.remove_at(i)
			$PinManager.activate_pin(status)
			if status in _expired_status_queue:
				$PinManager.remove_pins([status] as Array[StatusEffect])
			return true
	return false


func animate_phobia_activation(element: ElementalType) -> void:
	var i := -1
	for status in _activated_status_queue:
		i += 1
		if status.id != StatusEffect.Effects.PHOBIC: continue
		if status.element == element:
			_activated_status_queue.remove_at(i)
			$PinManager.activate_pin(status)


func _append_new_status_effect(effect: StatusEffect) -> void: 
	_new_status_queue.append(effect)


func _append_expired_status_effect(effects: Array[StatusEffect]) -> void: 
	_expired_status_queue += effects


func _append_status_activation(effect: StatusEffect, data:Variant=null) -> void:
	_activated_status_queue.append(effect)
	# $PinManager.activate_pin(effect)
	# helper_text_requested.emit(effect.name, ProjectSettings.get_setting("custom/general/helper_text_interval"))


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
