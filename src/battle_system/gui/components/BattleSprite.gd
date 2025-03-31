extends Node3D

signal selected(actor: BattleActor)
signal status_effect_icon_pressed(effect)

@export var transmutation_hint: Control
@export var use_gradient := true:
	set(val):
		use_gradient = val
		if val:
			$Primary.show()
			$Secondary.show()
			$Mesh.hide()
		else:
			$Primary.hide()
			$Secondary.hide()
			$Mesh.show()

var tint: Color = Color.WHITE
var is_selectable := false
var actor: BattleActor

var _mat1: StandardMaterial3D
var _mat2: StandardMaterial3D
var _indicator_mat: StandardMaterial3D
var _particle_mat: StandardMaterial3D
var _is_defeated := false

func setup(actor: BattleActor, shiftRight: bool) -> void:
	self.actor = actor
	_is_defeated = false
	_mat1 = StandardMaterial3D.new()
	_mat2 = StandardMaterial3D.new()
	_indicator_mat = StandardMaterial3D.new()
	_particle_mat = StandardMaterial3D.new()

	$Primary.set_surface_override_material(0, _mat1)
	$Secondary.set_surface_override_material(0, _mat2)
	$Indicator.set_surface_override_material(0, _indicator_mat)
	$GPUParticles3D.draw_pass_1.material = _particle_mat

	_mat1.albedo_color = actor.element1.main_color
	_mat2.albedo_color = actor.element2.main_color
	_indicator_mat.albedo_color = Color.DARK_GRAY

	if shiftRight:
		$PinManager/PhobiaCrown.rotation_degrees.y += 180

	actor.status_effect_added.connect(add_status_effect)
	actor.status_effects_removed.connect(remove_status_effects)
	actor.was_just_defeated.connect(func(): 
		_indicator_mat.albedo_color = Color.BLACK
		_mat1.albedo_color = _mat1.albedo_color.darkened(0.5)
		_mat2.albedo_color = _mat2.albedo_color.darkened(0.5)
		_is_defeated = true)
	actor.action_selected.connect(func(action: _BattleAction):
		if not Settings.show_opponent_intentions or action.element.is_blank():
			$GPUParticles3D.emitting = false
			return
		$GPUParticles3D.emitting = true
		_particle_mat.albedo_color = action.element.main_color)


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

func show_intentions(val: bool) -> void:
	$GPUParticles3D.emitting = val
	$GPUParticles3D.visible = val

func _on_mouse_entered() -> void:
	if is_selectable:
		set_highlight(true)
		transmutation_hint.activate()

func _on_mouse_exited() -> void:
	if is_selectable:
		set_highlight(false)
		transmutation_hint.deactivate()


func _on_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
			selected.emit(actor)
			transmutation_hint.deactivate()

func add_status_effect(effect: StatusEffect) -> void:
	$PinManager.insert_pin(effect)

func remove_status_effects(effects) -> void:
	$PinManager.remove_pins(effects)

func _on_pin_selected(effect: StatusEffect) -> void:
	status_effect_icon_pressed.emit(effect)

