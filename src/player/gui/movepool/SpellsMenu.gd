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

func setup(actor: BattleActor) -> void:
	if Engine.is_editor_hint(): return

	_actor = actor
	_button_group = ButtonGroup.new()

	var slots := moveset_scroller.get_children().slice(1)
	_actor.attacks.resize(len(slots))
	var i := 0
	for attack in actor.attacks:
		var slot = slots[i]
		slot.set_spell(attack, i)

		actor.spell_learned.connect(func(spell, index): 
			if slot.index == index: slot.set_spell(spell, index))
		i += 1
		slot.button_group = _button_group

	# Populate movepool
	movepool_submenu.setup()


func _on_moveset_slot_pressed(isEmpty: bool, index: int) -> void:
	display.allow_forgetting = len(_actor.attacks.filter(func(x): return x != null)) > 0

	if isEmpty:
		tab_container.current_tab = 1
		display.view_mode = SpellMenuDisplay.ViewMode.REPLACE
		var scroll = await display.spell_selected
		tab_container.current_tab = 0

		if scroll == null: return

		# _actor.attacks[index] = scroll.spell
		var failedReqs = _actor.learn_spell(scroll, index)
		if len(failedReqs) == 0: return

		# If user could not learn attack, inform player as to why.
		var msg = "%s cannot learn this spell, as they do not meet certain requirements.\n\nFailed requirements:\n" % _actor.name
		for req in failedReqs:
			msg += "%s\n" % req.get_requirement_message()

		popup.dialog_text = msg
		popup.show()


	else:
		display.view_mode = SpellMenuDisplay.ViewMode.INFO
		display.show_info(_actor.attacks[index], index)


func _on_spell_menu_display_forget_spell_requested(index: int) -> void:
	_actor.learn_spell(null, index)
