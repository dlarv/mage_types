extends Menu

signal golem_placed(wasPlaced: bool)

const GolemPrefab := preload("res://src/golem_system/golem.tscn")

var element_1 := ElementManager.Blue
var element_2 := ElementManager.Blue

var _golem: Golem = null


func _unhandled_input(event: InputEvent) -> void:
	if not _golem: return
	if event.is_action_pressed("ui_cancel"):
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
	battleActor.set_element(0, element_1)
	battleActor.set_element(1, element_2)

	var golem = GolemPrefab.instantiate()
	golem.setup(battleActor, instructions)

	_golem = golem
	add_child(golem)
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
		UIManager._on_golem_creator_button_pressed()
	UIManager.block_input = false
	_golem = null


func _on_element_dropdown_item_selected(index:int, id:int) -> void:
	var element: ElementalType
	if index == 0:
		element = ElementManager.Blank
	else:
		element = ElementManager.elements[index - 1]

	if id == 0:
		element_1 = element
	else:
		element_2 = element 
