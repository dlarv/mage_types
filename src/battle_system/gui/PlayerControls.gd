extends PanelContainer

signal action_selected(index: int, action: _BattleAction)
signal action_target_selection_cancelled()
signal end_turn(tryRunAway: bool)
signal show_info(action: _BattleAction, limitInfo: bool)
signal active_actor_changed(index: int)
signal start_turn()

const ThreeStateButton := preload("res://src/battle_system/gui/components/three_state_button.tscn")

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
var _skip_indices: Array[bool] = []
var _allies: Array[BattleActor] = []
var _already_selected_action: Array[bool] = []
var _force_manual_end_turn := false

func _ready() -> void:
	_final_index = attacks_panel.get_child_count() - 1
	calc_character_selector_state(attacks_panel.current_tab)


func _unhandled_key_input(event: InputEvent) -> void:
	if blocking_panel.is_visible_in_tree(): return 
	if control_panel.current_tab == 0: 
		if event.is_action_pressed("open_battle_attack_menu"):
			control_panel.current_tab = 1
			get_window().set_input_as_handled()
		elif event.is_action_pressed("open_battle_item_menu"):
			control_panel.current_tab = 2
			get_window().set_input_as_handled()
		elif event.is_action_pressed("open_battle_character_menu"):
			control_panel.current_tab = 3
			get_window().set_input_as_handled()

	if event.is_action_pressed("battle_menu_back"):
		get_window().set_input_as_handled()
		_on_back_button_pressed()
	elif event.is_action_pressed("battle_next_character") and not next_button.disabled:
		get_window().set_input_as_handled()
		next_character()
	elif event.is_action_pressed("battle_prev_character") and not prev_button.disabled:
		get_window().set_input_as_handled()
		prev_character()
	elif event.is_action_pressed("battle_end_turn") and not end_button.disabled:
		get_window().set_input_as_handled()
		_on_end_turn_button_pressed()
		

func setup(allies: Array[BattleActor], items: Array[RegularItem], enemies: Array[BattleActor]) -> void:
	_allies = allies
	_skip_indices = []

	for i in len(allies):
		var ally := allies[i]
		populate_new_attack_menu(ally, i)
		_skip_indices.append(false)
		# Variable has to be set out here, otherwise it'll be passed by reference.
		var index := i

		attacks_panel.tab_selected.connect(func(tabIndex: int) -> void:
			if(tabIndex != index): return
			# Disable/Enable items based on reqs.
			for j: int in len(items):
				var item := items[j].battle_item
				var button := (items_scroller.get_child(j))
				button.is_locked = !item.is_action_available(ally)
			)

	populate_items_menu(items)
	populate_characters_menu(allies, enemies)

	_final_index = attacks_panel.get_child_count() - 1
	# Doing this activates the "check if available" method.
	attacks_panel.current_tab = attacks_panel.current_tab
	calc_character_selector_state(attacks_panel.current_tab)
	_reset_selected()


func populate_new_attack_menu(actor: BattleActor, index: int) -> void:
	var scroller := ScrollContainer.new()
	var grid := GridContainer.new()
	grid.columns = 2
	var group := ButtonGroup.new()

	grid.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
	grid.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
	scroller.add_child(grid)
	attacks_panel.add_child(scroller)

	var i := -1
	for attack: _BattleAction in actor.attacks:
		if attack == null: continue
		i += 1

		# Init.
		var button := ThreeStateButton.instantiate()
		button.button_group = group
		button.text = attack.name
		button.shortcut_keycode = "attack_shortcut_%s" % str(i + 1)
		button.state_changed.connect(func(state: int) -> void:
			on_action_selected(state, index, attack)) 
		grid.add_child(button)

		# Set button's color to match element.
		button.setup(attack.element)

		# Connect signals.
		end_turn.connect(func(_a: Variant) -> void: button.reset())


func populate_items_menu(items: Array[RegularItem]) -> void:
	var group := ButtonGroup.new()

	for item: RegularItem in items:
		var button := ThreeStateButton.instantiate()
		button.button_group = group
		button.text = item.name

		button.state_changed.connect(func(state: int) -> void: 
			on_action_selected(state, attacks_panel.current_tab, item.battle_item)
		)

		end_turn.connect(func(_v: Variant) -> void: button.reset())
		items_scroller.add_child(button)


func populate_characters_menu(allies: Array[BattleActor], enemies: Array[BattleActor]) -> void:
	var group := ButtonGroup.new()

	var label := Label.new()
	label.text = "Allies"
	character_scroller.add_child(label)

	for ally: BattleActor in allies:
		var button := Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = ally.name
		button.pressed.connect(func() -> void: show_info.emit(ally, false))

		character_scroller.add_child(button)

	label = Label.new()
	label.text = "Enemies"
	character_scroller.add_child(label)
	for enemy: BattleActor in enemies:
		var button := Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = enemy.name
		button.pressed.connect(func() -> void: 
			show_info.emit(enemy, not ProjectSettings.get_setting("custom/general/debug_mode"))
		)
		character_scroller.add_child(button)


func prev_character() -> void:
	control_panel.current_tab = 0
	var index := attacks_panel.current_tab

	for i in range(index - 1, _begin_index - 1, -1):
		index = max(i, _begin_index)
		if not _skip_indices[index]: break

	attacks_panel.current_tab = index

	active_actor_changed.emit(index)
	_force_manual_end_turn = true
	calc_character_selector_state(index)


func next_character() -> void:
	control_panel.current_tab = 0

	var index := attacks_panel.current_tab
	for i in range(index + 1, _final_index + 1):
		index = min(i, _final_index)
		if not _skip_indices[index]: break

	attacks_panel.current_tab = index

	_edge_index = max(index, _edge_index)

	active_actor_changed.emit(index)
	calc_character_selector_state(index)


func set_enabled(enable: bool) -> void:
	blocking_panel.visible = !enable
	if not enable: return
	_reset_selected()

	_skip_indices = []
	for ally in _allies:
		_skip_indices.append(ally.flinching or ally.is_defeated)
	_begin_index = _skip_indices.find(false)
	_final_index = _skip_indices.rfind(false)

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

	if _allow_end_turn \
			and ProjectSettings.get_setting("custom/battle/auto_end_turn") \
			and not _force_manual_end_turn:
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
		return

	show_info.emit(action)
	_already_selected_action[index] = true
	action_selected.emit(index, action)
	_allow_end_turn = _already_selected_action.min()


func _reset_selected() -> void:
	_already_selected_action = []
	var i := -1
	for ally in _allies:
		i += 1
		var val := ally.is_defeated or ally.flinching
		_already_selected_action.append(val)

		if val:
			action_selected.emit(i, null)
		
