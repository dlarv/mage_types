extends Node3D

signal selected(actor: BattleActor)

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

var _mat1: StandardMaterial3D
var _mat2: StandardMaterial3D
var _indicator_mat: StandardMaterial3D

var tint: Color = Color.WHITE
var is_selectable := false
var actor: BattleActor

func setup(actor: BattleActor) -> void:
	self.actor = actor
	_mat1 = StandardMaterial3D.new()
	_mat2 = StandardMaterial3D.new()
	_indicator_mat = StandardMaterial3D.new()

	$Primary.set_surface_override_material(0, _mat1)
	$Secondary.set_surface_override_material(0, _mat2)
	$Indicator.set_surface_override_material(0, _indicator_mat)

	_mat1.albedo_color = actor.element1.main_color
	_mat2.albedo_color = actor.element2.main_color
	_indicator_mat.albedo_color = Color.DARK_GRAY


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
	is_selectable = true
	tint = color

func disable_transmutation_hint() -> void:
	transmutation_hint.deactivate()


func enable_transmutation_hint(attackElement: ElementalType) -> void:
	transmutation_hint.setup(actor, attackElement, self.global_position)

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
