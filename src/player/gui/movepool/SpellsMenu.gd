@tool
extends MarginContainer

@export
var DEFAULT_SLOTS_COUNT = 5

@export
var MovesetSlot: PackedScene
@export
var tab_container: TabContainer
@export 
var movepool_submenu: Control
@export
var display: Control
@export
var moveset_scroller: VBoxContainer

var _button_group: ButtonGroup
var _actor: BattleActor

func setup(actor: BattleActor, movepool: Movepool):
	_actor = actor
	# Populate moveset
	for child in moveset_scroller.get_children():
		moveset_scroller.remove_child(child)

	_button_group = ButtonGroup.new()
	var index = 0
	for attack in actor.attacks:
		add_moveset_slot(attack, index)
	
	var length = DEFAULT_SLOTS_COUNT - moveset_scroller.get_child_count() 
	while length > 0:
		add_moveset_slot()
		length -= 1

	# Populate movepool
	if movepool != null: 
		movepool_submenu.setup(movepool)

func add_moveset_slot(attack=null, index=-1):
	var obj = MovesetSlot.instantiate()
	obj.button_group = _button_group
	moveset_scroller.add_child(obj)
	obj.show_info_requested.connect(_on_show_info.bind(true))
	obj.set_spell_requested.connect(_on_set_spell_requested)

	obj.set_spell(attack)
	obj.index = index

func remove_moveset_slot():
	# Try to remove first empty slot.
	# If all slots are filled, remove the last one.
	var child
	for c in moveset_scroller.get_children():
		child = c
		if child.is_empty():
			child.clear()
			return
	child.clear()


func _on_show_info(spell: Attack, replaceSpell=false):
	display.show_info(spell, replaceSpell)

func _on_set_spell_requested(slot):
	tab_container.current_tab = 1

func _on_spell_menu_display_spell_selected(spell: Attack):
	var selected_button = _button_group.get_pressed_button()
	if selected_button == null: return

	selected_button.set_spell(spell)
	var index = selected_button.index
	_actor.learn_spell(index, spell)

	tab_container.current_tab = 0
	selected_button.set_pressed_no_signal(false)

func _on_spell_menu_display_canceled():
	var selected_button = _button_group.get_pressed_button()
	tab_container.current_tab = 0

	if selected_button == null or selected_button.spell == null: return
	_on_show_info(selected_button.spell)

func _on_spell_menu_display_replace_spell_requested() -> void:
	tab_container.current_tab = 1

