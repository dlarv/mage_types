@tool
extends Control
class_name TeamDisplay 

signal selected(actor)
signal status_effect_icon_pressed(effect)

@export var display_prefab: PackedScene 
@export var display_parent: HBoxContainer 
@export
var shift_right: bool = false: 
	get: return shift_right
	set(value):
		shift_right = value
		if (display_parent == null): return
		if value:
			display_parent.alignment = BoxContainer.ALIGNMENT_END
		else:
			display_parent.alignment = BoxContainer.ALIGNMENT_BEGIN

var length: int: 
	get: return len(displays)

# BattleActorDisplay[]
var displays := []
var highlightedActorIndex: int = 0

func add_display(actor: BattleActor) -> BattleActorDisplay:
	var display = display_prefab.instantiate()
	display.setup(actor)
	displays.append(display)
	
	display_parent.add_child(display)
	if shift_right:
		display_parent.move_child(display, 0)

	display.selected.connect(func(a):
		selected.emit(a)
		for d in displays:
			d.disable_selection()
			if not Settings.enable_transmutation_hints: continue
			d.disable_transmutation_hint())

	display.status_effect_icon_pressed.connect(func(effect): status_effect_icon_pressed.emit(effect))

	return display

func get_display_from_index(index: int) -> BattleActorDisplay:
	if index < len(displays):
		return displays[index]
	return null

func get_display(actor: Variant) -> BattleActorDisplay:
	if(actor is int): return get_display_from_index(actor)
	for display in displays:
		if display.actor == actor:
			return display
	return null

## Allow the player to highlight and select one of the contained BattleActorDisplays.
func select_target(isAttack: bool, element: ElementalType) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN
	for display in displays:
		display.enable_selection(highlight)

		if Settings.enable_transmutation_hints:
			display.enable_transmutation_hint(element)

func select_all_as_target(isAttack: bool, element: ElementalType) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN

	if not Settings.enable_transmutation_hints: return 

	for display in displays:
		display.enable_transmutation_hint(element)

func cancel_target_selection():
	selected.emit(null)
	for d in displays:
		d.disable_selection()

		if Settings.enable_transmutation_hints:
			d.disable_transmutation_hint()

func enable_transmutation_hint(user: BattleActor, element: ElementalType):
	if not Settings.enable_transmutation_hints: return
	get_display(user).enable_transmutation_hint(element)


# Highlight the display of the currently active actor.
func highlight(index: int) -> void:
	displays[highlightedActorIndex].set_highlight(false)
	highlightedActorIndex = index
	displays[highlightedActorIndex].set_highlight(true)
