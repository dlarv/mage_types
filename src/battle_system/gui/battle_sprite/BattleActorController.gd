extends Node

signal helper_text_requested(msg: String, duration: float)
signal channeling_finished
signal defeated_finished

const BattleActorDisplay := preload("res://src/battle_system/gui/components/BattleActorDisplay.gd")

const EQUIPMENT_TEXT_DURATION := 0.8
const ENEMY_MODEL_ROTATION := 180.0

var flip_model_if_enemy := false

var actor: BattleActor

var _animation_state: AnimationNodeStateMachinePlayback
var _is_defeated := false


func setup(actor: BattleActor, display: BattleActorDisplay, isEnemy: bool) -> void:
	self.actor = actor
	
	$AnimationTree.active = true
	_animation_state = $AnimationTree["parameters/playback"]
	_animation_state.state_finished.connect(_on_state_finished)

	if not actor.equipment_activated.is_connected(_on_equipment_activated):
		actor.equipment_activated.connect(_on_equipment_activated)

	_is_defeated = false
	%EmitterController.is_ally = not isEnemy

	$MeshManager.setup(actor)

	$PinManager.status_manager = actor.statuses

	actor.status_effect_added.connect(add_status_effect)
	actor.status_effects_removed.connect(remove_status_effects)
	actor.was_just_defeated.connect(_on_actor_defeated) 
	actor.action_selected.connect(_on_action_selected)
	actor.status_activated.connect(animate_status_activation)
	actor.element_changed.connect(set_element)

	Battle.transmutations_started.connect(_on_transmutation_phase.bind(true))
	Battle.transmutations_finished.connect(_on_transmutation_phase.bind(false))

	if isEnemy and flip_model_if_enemy:
		$PinManager.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$PinManager/PhobiaCrown.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$MeshManager.mesh.rotation_degrees.y += ENEMY_MODEL_ROTATION


func _exit_tree() -> void:
	if self.actor.equipment_activated.is_connected(_on_equipment_activated):
		self.actor.equipment_activated.disconnect(_on_equipment_activated)

	actor.status_effect_added.disconnect(add_status_effect)
	actor.status_effects_removed.disconnect(remove_status_effects)
	actor.was_just_defeated.disconnect(_on_actor_defeated) 
	actor.action_selected.disconnect(_on_action_selected)
	actor.status_activated.disconnect(animate_status_activation)

	Battle.transmutations_started.disconnect(_on_transmutation_phase.bind(true))
	Battle.transmutations_finished.disconnect(_on_transmutation_phase.bind(false))


func play_intro() -> void:
	$MeshManager.play_intro()
	play_animation("battle_entry")


func set_element(id: int, element: ElementalType) -> void:
	$MeshManager.set_element(id, element)


func play_animation(name: String) -> void:
	_animation_state.travel(name)
	await _animation_state.state_finished


func has_animation(n: String) -> bool:
	return $AnimationTree.has_animation(n)


func start_channeling_particles(duration: float, strength: float) -> void:
	%EmitterController.play_channeling(duration, strength)


func add_status_effect(effect: StatusEffect) -> void: 
	$PinManager.insert_pin(effect)


func remove_status_effects(effects: Array[StatusEffect]) -> void: 
	$PinManager.remove_pins(effects)


func animate_status_activation(effect: StatusEffect, data:Variant=null) -> void:
	$PinManager.activate_pin(effect)
	helper_text_requested.emit(effect.name, ProjectSettings.get_setting("custom/general/helper_text_interval"))


func _on_state_finished(stateName: String) -> void:
	match stateName:
		"channeling":
			channeling_finished.emit()
		"defeated":
			defeated_finished.emit()


func _on_transmutation_phase(a: BattleActor, started: bool) -> void:
	if a != actor: return
	$MeshManager.fade_aura(started)


func _on_equipment_activated(equipment: Equipment) -> void:
	helper_text_requested.emit(equipment.name, EQUIPMENT_TEXT_DURATION)


func _on_actor_defeated() -> void:
	$PinManager.hide_pins.call()
	$MeshManager.set_defeated()
	_is_defeated = true


func _on_action_selected(action: _BattleAction) -> void:
	%EmitterController.set_action_element(action.element)
