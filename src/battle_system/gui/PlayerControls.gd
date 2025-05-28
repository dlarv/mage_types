extends PanelContainer

signal action_selected(index, action)
signal action_target_selection_cancelled()
signal end_turn(tryRunAway)
signal show_info(action, limitInfo)
signal active_actor_changed(index)
signal start_turn()

@export var three_state_button: PackedScene 
@export var control_panel: TabContainer 
@export var attacks_panel: TabContainer 
@export var items_scroller: GridContainer
@export var character_scroller: VBoxContainer 
@export var next_button: Button 
@export var prev_button: Button 
@export var end_button: Button 
@export var blocking_panel: Panel 

# The index of the rightmost character who has selected an action.
var _edge_index: int = 0
# Index to reset to when a new turn is begun.
var _begin_index: int = 0
var _final_index: int = 0
var _allow_end_turn: bool = false
# List of indices of defeated actors.
# bool[]
var _skip_indices := []
# BattleActor[]
var _allies := []
var _selected_actions := []
var _force_manual_end_turn := false

func _ready() -> void:
	_final_index = attacks_panel.get_child_count() - 1
	calc_character_selector_state(attacks_panel.current_tab)


func setup(allies: Array, items: Array, enemies: Array) -> void:
	_skip_indices = []
	self._allies = allies
	_selected_actions = []

	for i in range(len(allies)):
		var ally = allies[i]
		_selected_actions.append(0)
		populate_new_attack_menu(ally, i)
		_skip_indices.append(false)
		# Variable has to be set out here, otherwise it'll be passed by reference.
		var index = i
		ally.was_just_defeated.connect(func():
			_skip_indices[index] = true
			# Recalc _begin_index and _final_index.
			_final_index = _skip_indices.rfind(false)
			_begin_index = _skip_indices.find(false))

		attacks_panel.tab_selected.connect(func(tabIndex):
			if(tabIndex != index): return
			# Disable/Enable attacks based on mana.
			for j in range(len(ally.attacks)):
				if ally.attacks[j] == null: continue
				var attack = ally.attacks[j]
				var button = (attacks_panel.get_child(index).get_child(0).get_child(j))
				button.is_locked = !attack.is_action_available(ally)

			# Disable/Enable items based on reqs.
			for j in range(len(items)):
				var item = items[j]
				var button = (items_scroller.get_child(j))
				button.is_locked = !item.is_action_available(ally)
			)

	populate_items_menu(items)
	populate_characters_menu(allies, enemies)

	_final_index = attacks_panel.get_child_count() - 1
	# Doing this activates the "check if available" method.
	attacks_panel.current_tab = attacks_panel.current_tab
	calc_character_selector_state(attacks_panel.current_tab)


func populate_new_attack_menu(actor: BattleActor, index: int) -> void:
	var scroller := ScrollContainer.new()
	var grid := GridContainer.new()
	grid.columns = 2
	var group := ButtonGroup.new()

	grid.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
	grid.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
	scroller.add_child(grid)
	attacks_panel.add_child(scroller)

	for attack in actor.attacks:
		if attack == null: continue
		# Init.
		var button = three_state_button.instantiate()
		button.button_group = group
		button.text = attack.name
		button.state_changed.connect(func(state):
			on_action_selected(state, index, attack)) 
		grid.add_child(button)

		# Set button's color to match element.
		button.setup(attack.element)

		# Connect signals.
		end_turn.connect(func(a): button.reset())


func populate_items_menu(items) -> void:
	var group = ButtonGroup.new()

	for item in items:
		var button = three_state_button.instantiate()
		button.button_group = group
		button.text = item.name

		button.state_changed.connect(func(state): on_action_selected(state, attacks_panel.current_tab, item))

		end_turn.connect(func(val): button.reset())
		items_scroller.add_child(button)


func populate_characters_menu(allies, enemies) -> void:
	var group = ButtonGroup.new()

	var label = Label.new()
	label.text = "Allies"
	character_scroller.add_child(label)

	for ally in allies:
		var button = Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = ally.name
		button.pressed.connect(func(): show_info.emit(ally, false))

		character_scroller.add_child(button)

	label = Label.new()
	label.text = "Enemies"
	character_scroller.add_child(label)
	for enemy in enemies:
		var button = Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = enemy.name
		button.pressed.connect(func(): show_info.emit(enemy, not Settings.debug_mode))
		character_scroller.add_child(button)


func prev_character() -> void:
	control_panel.current_tab = 0
	var index = attacks_panel.current_tab

	for i in range(index - 1, _begin_index - 1, -1):
		index = max(i, _begin_index)
		if(not _skip_indices[index]): break

	attacks_panel.current_tab = index

	active_actor_changed.emit(index)
	_force_manual_end_turn = true
	calc_character_selector_state(index)


func next_character() -> void:
	control_panel.current_tab = 0

	var index = attacks_panel.current_tab
	# for(int i = 1 index + i <= _final_index + 1 i++) {
	for i in range(index + 1, _final_index + 1):
		index = min(i, _final_index)
		if(not _skip_indices[index]): break


	attacks_panel.current_tab = index

	_edge_index = max(index, _edge_index)

	active_actor_changed.emit(index)
	calc_character_selector_state(index)

func set_enabled(enable: bool) -> void:
	blocking_panel.visible = !enable
	if not enable: return
	_reset_selected()

	# Reset to first character.
	attacks_panel.current_tab = _begin_index
	_edge_index = _begin_index
	calc_character_selector_state(_begin_index)
	active_actor_changed.emit(_begin_index)
	
	start_turn.emit()

func _on_end_turn_button_pressed() -> void:
	end_button.release_focus()
	control_panel.current_tab = 0
	_allow_end_turn = false
	_force_manual_end_turn = false
	end_turn.emit(false)

func calc_character_selector_state(index: int) -> void:
	prev_button.disabled = index == _begin_index
	next_button.disabled = index == _edge_index
	end_button.disabled = !_allow_end_turn

	if _allow_end_turn and Settings.auto_end_turn and not _force_manual_end_turn:
		_on_end_turn_button_pressed()

func _on_attacks_button_pressed() -> void:
	control_panel.current_tab = 1

func _on_items_button_pressed() -> void:
	control_panel.current_tab = 2

func _on_characters_button_pressed() -> void:
	control_panel.current_tab = 3

func _on_run_button_pressed() -> void:
	end_turn.emit(true)

func _on_back_button_pressed() -> void:
	control_panel.current_tab = 0
	action_target_selection_cancelled.emit()

func on_action_selected(state: int, index: int, action: _BattleAction) -> void:
	# Press 1: Show info & select target
	# Press 2: Goto default.
	if not state:
		action_target_selection_cancelled.emit()
	else:
		show_info.emit(action)
		_selected_actions[index] = 1
		_allow_end_turn = _selected_actions.min() == 1
		action_selected.emit(index, action)

func _reset_selected() -> void:
	for i in len(_allies):
		_selected_actions[i] = int(_allies[i].is_defeated)
		
