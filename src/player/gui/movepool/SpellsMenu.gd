@tool
extends MarginContainer

@export var DEFAULT_SLOTS_COUNT = 5

@export var MovesetSlot: PackedScene
@export var tab_container: TabContainer
@export var movepool_submenu: Control
@export var display: Control
@export var moveset_scroller: VBoxContainer
@export var popup: AcceptDialog

var _button_group: ButtonGroup
var _actor: BattleActor

func setup(actor: BattleActor, movepool: Movepool) -> void:
	_actor = actor
	# Populate moveset
	for child in moveset_scroller.get_children():
		moveset_scroller.remove_child(child)

	_button_group = ButtonGroup.new()
	var index = 0
	for attack in actor.attacks:
		add_moveset_slot(attack, index)
		index += 1
	
	var length = DEFAULT_SLOTS_COUNT - moveset_scroller.get_child_count() 
	while length > 0:
		add_moveset_slot(null, index)
		index += 1
		length -= 1

	# Populate movepool
	if movepool != null: 
		movepool_submenu.setup(movepool)

func add_moveset_slot(attack=null, index=-1) -> void:
	var obj = MovesetSlot.instantiate()
	obj.button_group = _button_group
	moveset_scroller.add_child(obj)
	obj.show_info_requested.connect(_on_show_info.bind(true))
	obj.set_spell_requested.connect(_on_set_spell_requested)

	obj.set_spell(attack)
	obj.index = index

func remove_moveset_slot() -> void:
	# Try to remove first empty slot.
	# If all slots are filled, remove the last one.
	var child
	for c in moveset_scroller.get_children():
		child = c
		if child.is_empty():
			child.clear()
			return
	child.clear()

func set_moveset_slot(scroll: SpellScroll, index: int) -> void:
	moveset_scroller.get_child(index).set_spell(scroll.spell)

# Where spell is SpellScroll or Attack.
func _on_show_info(spell, replaceSpell=false) -> void:
	display.show_info(spell, replaceSpell)

func _on_set_spell_requested(slot) -> void:
	tab_container.current_tab = 1

func _on_spell_menu_display_spell_selected(scroll: SpellScroll) -> void:
	var selected_button = _button_group.get_pressed_button()
	if selected_button == null: return

	var index = selected_button.index

	tab_container.current_tab = 0
	selected_button.set_pressed_no_signal(false)
	var failed_reqs = _actor.learn_spell(scroll, index)

	if len(failed_reqs) == 0: 
		selected_button.set_spell(scroll.spell)
		return

	var msg = "%s cannot learn this spell, as they do not meet certain requirements.\n\nFailed requirements:\n" % _actor.name

	for req in failed_reqs:
		msg += "%s\n" % req.get_requirement_message()

	popup.dialog_text = msg
	popup.show()

func _on_spell_menu_display_canceled() -> void:
	var selected_button = _button_group.get_pressed_button()
	tab_container.current_tab = 0

	if selected_button == null or selected_button.spell == null: return
	_on_show_info(selected_button.spell)

func _on_spell_menu_display_replace_spell_requested() -> void:
	tab_container.current_tab = 1
