extends PanelContainer
class_name PlayerControls 


signal action_selected(index, action)
signal end_turn(tryRunAway)
signal show_info(action)
signal active_actor_changed(index)

@export
var threeStateButton: PackedScene 
@export
var controlPanel: TabContainer 
@export
var attacksPanel: TabContainer 
@export
var itemsScroller: VBoxContainer 
@export
var characterScroller: VBoxContainer 
@export
var nextButton: Button 
@export
var prevButton: Button 
@export
var endButton: Button 
@export
var blockingPanel: Panel 

# The index of the rightmost character who has selected an action.
var edgeIndex : int = 0
# Index to reset to when a new turn is begun.
var beginIndex : int = 0
var finalIndex : int = 0
var allowEndTurn : bool = false
# List of indices of defeated actors.
# bool[]
var skipIndices = []
# BattleACtor[]
var allies = []

func _ready() -> void:
	finalIndex = attacksPanel.get_child_count() - 1
	calc_character_selector_state(attacksPanel.current_tab)

func setup(allies, items, enemies) -> void:
	skipIndices = []
	self.allies = allies

	for i in range(len(allies)):
		var ally = allies[i]
		populate_new_attack_menu(ally, i)
		skipIndices.append(false)
		# Variable has to be set out here, otherwise it'll be passed by reference.
		var index = i
		ally.was_just_defeated.connect(func():
			skipIndices[index] = true
			# Recalc beginIndex and finalIndex.
			finalIndex = skipIndices.rfind(false)
			beginIndex = skipIndices.find(false)
		)

		attacksPanel.tab_selected.connect(func(tabIndex):
			if(tabIndex != index): return
			# Disable/Enable attacks based on mana.
			for j in range(len(ally.attacks)):
				var attack = ally.attacks[j]
				var button = (attacksPanel.get_child(index).get_child(0).get_child(j))
				button.is_locked = !attack.is_action_available(ally)

			# Disable/Enable items based on reqs.
			for j in range(len(items)):
				var item = items[j]
				var button = (itemsScroller.get_child(j))
				button.is_locked = !item.is_action_available(ally)
			)

	populate_items_menu(items)
	populate_characters_menu(allies, enemies)

	finalIndex = attacksPanel.get_child_count() - 1
	# Doing this activates the "check if available" method.
	attacksPanel.current_tab = attacksPanel.current_tab
	calc_character_selector_state(attacksPanel.current_tab)

func populate_new_attack_menu(actor: BattleActor, index: int) -> void:
	var scroller = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	var group = ButtonGroup.new()

	vbox.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
	scroller.add_child(vbox)

	for attack in actor.attacks:
		var button = threeStateButton.instantiate()
		button.button_group = group
		button.text = attack.name
		button.state_changed.connect(func(state):
			on_action_selected(state, index, attack)) 

		end_turn.connect(func(a): button.reset())
		vbox.add_child(button)

	attacksPanel.add_child(scroller)

func populate_items_menu(items) -> void:
	var group = ButtonGroup.new()

	for item in items:
		var button = threeStateButton.instantiate()
		button.button_group = group
		button.text = item.name

		button.state_changed.connect(func(state): on_action_selected(state, attacksPanel.current_tab, item))

		end_turn.connect(func(val): button.reset())
		itemsScroller.add_child(button)


func populate_characters_menu(allies, enemies) -> void:
	var group = ButtonGroup.new()

	var label = Label.new()
	label.text = "Allies"
	characterScroller.add_child(label)

	for ally in allies:
		var button = Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = ally.name
		button.pressed.connect(func(): show_info.emit(ally))

		characterScroller.add_child(button)


	label = Label.new()
	label.text = "Enemies"
	characterScroller.add_child(label)
	for enemy in enemies:
		var button = Button.new()
		button.button_group = group
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.size_flags_vertical = Button.SIZE_EXPAND_FILL
		button.text = enemy.name
		button.pressed.connect(func(): show_info.emit(enemy))
		characterScroller.add_child(button)


func prev_character() -> void:
	controlPanel.current_tab = 0
	var index = attacksPanel.current_tab

	# for(int i = 1 index - i >= beginIndex - 1 i++) {
	# 	index = Math.Max(index - i, beginIndex)
	# 	if(!skipIndices[index]) break
	for i in range(index - 1, beginIndex - 1, -1):
		index = max(i, beginIndex)
		if(not skipIndices[index]): break

	attacksPanel.current_tab = index

	active_actor_changed.emit(index)
	calc_character_selector_state(index)

func next_character() -> void:
	controlPanel.current_tab = 0

	var index = attacksPanel.current_tab
	# for(int i = 1 index + i <= finalIndex + 1 i++) {
	for i in range(index + 1, finalIndex + 1):
		index = min(i, finalIndex)
		if(not skipIndices[index]): break


	attacksPanel.current_tab = index

	edgeIndex = max(index, edgeIndex)

	active_actor_changed.emit(index)
	calc_character_selector_state(index)

func set_enabled(enable: bool) -> void:
	blockingPanel.visible = !enable
	if enable:
		attacksPanel.current_tab = beginIndex
		edgeIndex = beginIndex
		calc_character_selector_state(beginIndex)
		active_actor_changed.emit(beginIndex)


func _on_end_turn_button_pressed() -> void:
	controlPanel.current_tab = 0
	allowEndTurn = false
	end_turn.emit(false)

func calc_character_selector_state(index: int) -> void:
	prevButton.disabled = index == beginIndex
	nextButton.disabled = index == edgeIndex
	endButton.disabled = !allowEndTurn

func _on_attacks_button_pressed() -> void:
	controlPanel.current_tab = 1

func _on_items_button_pressed() -> void:
	controlPanel.current_tab = 2

func _on_characters_button_pressed() -> void:
	controlPanel.current_tab = 3

func _on_run_button_pressed() -> void:
	end_turn.emit(true)

func _on_back_button_pressed() -> void:
	controlPanel.current_tab = 0

func on_action_selected(state: int, index: int, action: BattleAction) -> void:
	match state:
		ThreeStateButton.FIRST_SELECTED_STATE:
			show_info.emit(action)
		ThreeStateButton.SECOND_SELECTED_STATE:
			action_selected.emit(index, action)
			allowEndTurn = edgeIndex >= finalIndex
