extends Node3D

signal hovered(actor: BattleActor)
signal selected(actor: BattleActor)
signal status_effect_icon_pressed(effect: StatusEffect)

@export var transmutation_hint: Control
@export var mesh: MeshInstance3D

var tint: Color = Color.WHITE
var is_selectable := false
var actor: BattleActor

var _mat1: StandardMaterial3D
var _mat2: StandardMaterial3D
var _indicator_mat: StandardMaterial3D
var _is_defeated := false
var _animation_player: AnimationPlayer


func setup(actor: BattleActor, isEnemy: bool) -> void:
	self.actor = actor
	_is_defeated = false
	%EmitterController.is_ally = not isEnemy

	_mat1 = StandardMaterial3D.new()
	_mat2 = StandardMaterial3D.new()
	_indicator_mat = StandardMaterial3D.new()

	_mat1 = mesh.get_active_material(0)
	_mat2 = mesh.get_active_material(1)

	var animationPlayerParent: Node = mesh
	while animationPlayerParent.get_parent() != self:
		animationPlayerParent = animationPlayerParent.get_parent()

	_animation_player = animationPlayerParent.find_child("AnimationPlayer", true) 
	if _animation_player and _animation_player.has_animation("battle_stance"):
		_animation_player.play("battle_stance")

	$Indicator.set_surface_override_material(0, _indicator_mat)

	_mat1.albedo_color = actor.element1.main_color
	_mat2.albedo_color = actor.element2.main_color
	_indicator_mat.albedo_color = Color.DARK_GRAY

	if isEnemy:
		$PinManager.rotation_degrees.y += 180
		$PinManager/PhobiaCrown.rotation_degrees.y += 180

	$PinManager.status_manager = actor.statuses

	actor.status_effect_added.connect(add_status_effect)
	actor.status_effects_removed.connect(remove_status_effects)
	actor.was_just_defeated.connect(func() -> void: 
		_indicator_mat.albedo_color = Color.BLACK
		_mat1.albedo_color = _mat1.albedo_color.darkened(0.5)
		_mat2.albedo_color = _mat2.albedo_color.darkened(0.5)
		_is_defeated = true)
	actor.action_selected.connect(_on_action_selected)
	actor.status_activated.connect(animate_status_activation)


func set_element(id: int, element: ElementalType) -> void:
	if id == 0:
		_mat1.albedo_color = element.main_color
	else:
		_mat2.albedo_color = element.main_color


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


func play_animation(name: String) -> void:
	if not _animation_player: return
	if not _animation_player.has_animation(name):
		push_error("BattleSprite(%s) is missing Animation(%s)!" % [actor.name, name])
		return

	_animation_player.play(name)
	await _animation_player.animation_finished


func get_animation_duration(name: String) -> float:
	if not _animation_player or not _animation_player.has_animation(name): return 0.0
	return _animation_player.get_animation(name).length


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


func add_status_effect(effect: StatusEffect) -> void:
	$PinManager.insert_pin(effect)


func remove_status_effects(effects: Array[StatusEffect]) -> void:
	$PinManager.remove_pins(effects)


func _on_pin_selected(effect: StatusEffect) -> void:
	status_effect_icon_pressed.emit(effect)


func animate_status_activation(effect: StatusEffect
) -> void:
	$PinManager.activate_pin(effect)
