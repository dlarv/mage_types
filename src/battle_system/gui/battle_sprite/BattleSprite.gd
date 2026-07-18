extends Node3D

signal hovered(actor: BattleActor)
signal selected(actor: BattleActor)
signal status_effect_icon_pressed(effect: StatusEffect)
signal channeling_finished
signal defeated_finished

const ALLY_FONT_SIZE := 45
const ENEMY_FONT_SIZE := 64
const ACTION_FONT_SIZE_MODIFER := 1.2
const EQUIPMENT_TEXT_DURATION := 0.8
const ACTION_TEXT_DURATION := 0.8
const ENEMY_MODEL_ROTATION := 212.5

@export var transmutation_hint: Control

var tint: Color = Color.WHITE
var is_selectable := false
var actor: BattleActor
var _indicator_mat: StandardMaterial3D
var _is_defeated := false
var _animation_state: AnimationNodeStateMachinePlayback


func setup(actor: BattleActor, isEnemy: bool) -> void:
	self.actor = actor
	if not self.actor.equipment_activated.is_connected(_on_equipment_activated):
		self.actor.equipment_activated.connect(_on_equipment_activated)

	_animation_state = $AnimationTree["parameters/playback"]
	_animation_state.state_finished.connect(_on_state_finished)

	_is_defeated = false
	%EmitterController.is_ally = not isEnemy

	$MeshManager.setup(actor)

	_indicator_mat = StandardMaterial3D.new()
	_indicator_mat.albedo_color = Color.DARK_GRAY
	$Indicator.set_surface_override_material(0, _indicator_mat)

	if isEnemy:
		$PinManager.rotation_degrees.y += ENEMY_MODEL_ROTATION
		$PinManager/PhobiaCrown.rotation_degrees.y += ENEMY_MODEL_ROTATION

		$Label3D.font_size = ENEMY_FONT_SIZE
		$ActionLabel3D.font_size = ENEMY_FONT_SIZE * ACTION_FONT_SIZE_MODIFER
		$MeshManager.mesh.rotation_degrees.y += ENEMY_MODEL_ROTATION
	else:
		$Label3D.font_size = ALLY_FONT_SIZE
		$ActionLabel3D.font_size = ALLY_FONT_SIZE * ACTION_FONT_SIZE_MODIFER

	$PinManager.status_manager = actor.statuses

	actor.status_effect_added.connect(add_status_effect)
	actor.status_effects_removed.connect(remove_status_effects)
	actor.was_just_defeated.connect(func() -> void: 
		_indicator_mat.albedo_color = Color.BLACK
		$MeshManager.set_defeated()
		_is_defeated = true)
	actor.action_selected.connect(_on_action_selected)
	actor.status_activated.connect(animate_status_activation)

	$ActionLabel3D.position = $Label3D.position
	$ActionLabel3D.position.y -= 0.3


func _exit_tree() -> void:
	if self.actor.equipment_activated.is_connected(_on_equipment_activated):
		self.actor.equipment_activated.disconnect(_on_equipment_activated)


func set_element(id: int, element: ElementalType) -> void:
	$MeshManager.set_element(id, element)


func disable_selection() -> void:
	is_selectable = false
	# If this is white, then its the indicator showing which character is currently active.
	# Otherwise, its red or green, which indicate this character is being targeted.
	if _indicator_mat.albedo_color != Color.WHITE:
		tint = Color.WHITE
		set_highlight(false)


func enable_selection(color: Color) -> void:
	if _is_defeated: return
	is_selectable = true
	tint = color


func disable_transmutation_hint() -> void:
	transmutation_hint.deactivate()


func enable_transmutation_hint(action: _BattleAction) -> void:
	transmutation_hint.setup(actor, action, self.global_position)


func set_highlight(isHighlighted: bool) -> void:
	if not isHighlighted:
		_indicator_mat.albedo_color = Color.DARK_GRAY
	else:
		_indicator_mat.albedo_color =  Color(tint.r, tint.g, tint.b, 1 if isHighlighted else 0)


func get_target_position() -> Vector2:
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(global_position)
	pos2D.x += scale.x / 2
	pos2D.y += scale.y / 2
	return pos2D


func toggle_intentions(val: bool) -> void: %EmitterController.toggle_intentions(val)


func play_intro() -> void:
	$MeshManager.play_intro()


func play_animation(name: String) -> void:
	_animation_state.travel(name)
	await _animation_state.state_finished


func has_animation(n: String) -> bool:
	return $AnimationTree.has_animation(n)


func start_channeling_particles(duration: float, strength: float) -> void:
	%EmitterController.play_channeling(duration, strength)


func _on_mouse_entered() -> void:
	if is_selectable:
		hover(true)


func _on_mouse_exited() -> void:
	if is_selectable:
		hover(false)


func _on_action_selected(action: _BattleAction) -> void:
	%EmitterController.set_action_element(action.element)


func hover_no_signal(highlight: bool) -> void:
	set_highlight(highlight)
	transmutation_hint.set_active(highlight)


# listener calls hover_no_signal(), which is where logic is kept.
func hover(highlight: bool) -> void:
	hovered.emit(actor)


func _on_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			select()


func select() -> void:
	selected.emit(actor)
	transmutation_hint.deactivate()


func add_status_effect(effect: StatusEffect) -> void: $PinManager.insert_pin(effect)


func remove_status_effects(effects: Array[StatusEffect]) -> void: $PinManager.remove_pins(effects)


func _on_pin_selected(effect: StatusEffect) -> void: status_effect_icon_pressed.emit(effect)


func animate_status_activation(effect: StatusEffect, data:Variant=null) -> void:
	$PinManager.activate_pin(effect)
	set_helper_text(effect.name, Settings.helper_text_interval)


func set_helper_text(msg: String, duration: float) -> void: 
	$Label3D.text = msg
	if is_inside_tree():
		await get_tree().create_timer(duration).timeout
	$Label3D.text = ""


func set_action_text(action: _BattleAction) -> void:
	$ActionLabel3D.text = action.name
	var tween := get_tree().create_tween()
	var pos: Vector3 = $ActionLabel3D.position
	tween.tween_property($ActionLabel3D, "position", pos + Vector3(0, .3, 0), 1.0)

	await tween.finished

	$ActionLabel3D.text = ""
	$ActionLabel3D.position = pos


func _on_equipment_activated(equipment: Equipment) -> void:
	set_helper_text(equipment.name, EQUIPMENT_TEXT_DURATION)


func _on_state_finished(stateName: String) -> void:
	match stateName:
		"channeling":
			channeling_finished.emit()
		"defeated":
			defeated_finished.emit()
