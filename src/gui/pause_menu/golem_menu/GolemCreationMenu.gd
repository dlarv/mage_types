extends Menu

signal golem_placed(wasPlaced: bool)

const GolemPrefab := preload("res://src/golem_system/golem.tscn")

@onready var element := ElementManager.Blue:
	set(val):
		if not val or val.is_blank():
			return
		else:
			%ElementDropdown.select(ElementManager.get_index_from_name(val.name))
			%ElementIcon.element = val
			element = val
var _golem: Golem = null


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("open_golem_menu"):
		UIManager.toggle_golem_menu(null)
		return

	if not _golem: return
	if event.is_action_pressed("ui_cancel") \
			or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT):
		get_viewport().set_input_as_handled()
		golem_placed.emit(false)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		golem_placed.emit(true)


func _process(delta: float) -> void:
	if not _golem: return
	var cam := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mousePos)
	var to := from + cam.project_ray_normal(mousePos) * 1000

	var spaceState := _golem.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := spaceState.intersect_ray(query)

	if "position" in result:
		_golem.global_position = result.position


func _on_finish_button_pressed() -> void:
	var instructions = %GolemInstructionManager.get_instructions()
	var battleActor := BattleActor.new()
	battleActor.set_element(0, element)
	battleActor.set_element(1, element)

	var golem = GolemPrefab.instantiate()
	_golem = golem
	add_child(golem)
	golem.setup(battleActor, instructions)

	UIManager.clear_all()
	UIManager.block_input = true
	get_tree().paused = true
	if await golem_placed:
		var p = get_tree().get_nodes_in_group("player") 
		if len(p) > 0:
			remove_child(golem)
			get_tree().paused = false
			p[0].create_golem(golem)
	else:
		# Reopen creator menu
		remove_child(golem)
		get_tree().paused = false
		UIManager.toggle_golem_menu()
	UIManager.block_input = false
	_golem = null


func _on_element_dropdown_item_selected(index:int) -> void:
	element = ElementManager.elements[index]


func _draw() -> void:
	%DebugElementHBox.visible = Settings.debug_mode
	%ElementIcon.visible = not Settings.debug_mode

