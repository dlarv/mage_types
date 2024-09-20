@tool
extends Control
class_name TeamDisplay 

signal Selected(actor, i)
signal StatusEffectIconPressed(effect)

@export
var displayPrefab: PackedScene 
@export
var displayParent: HBoxContainer 
var _shiftRight
@export
var ShiftRight : bool: 
	get: return _shiftRight
	set(value):
		_shiftRight = value
		if (displayParent == null): return
		if value:
			displayParent.alignment = BoxContainer.ALIGNMENT_END
		else:
			displayParent.alignment = BoxContainer.ALIGNMENT_BEGIN

var Length: int: 
	get: return len(displays)

# BattleActorDisplay[]
var displays = []
var highlightedActorIndex : int = 0

func AddDisplay(actor: BattleActor) -> void:
	var display = displayPrefab.instantiate()
	display.Setup(actor)
	displays.append(display)
	displayParent.add_child(display)

	display.Selected.connect(func(a):
		Selected.emit(a, 11)
		for d in displays:
			d.DisableSelection())

	display.StatusEffectIconPressed.connect(func(effect): StatusEffectIconPressed.emit(effect))

func GetDisplayFromIndex(index: int) -> BattleActorDisplay:
	if index < len(displays):
		return displays[index]
	return null

func GetDisplay(actor) -> BattleActorDisplay:
	if(actor is int): return GetDisplayFromIndex(actor)
	for display in displays:
		if display.Actor == actor:
			return display
	return null

func SelectTarget(isAttack: bool) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN
	for display in displays:
		display.EnableSelection(highlight)

# Highlight the display of the currently active actor.
func Highlight(index: int) -> void:
	displays[highlightedActorIndex].SetHighlight(false)
	highlightedActorIndex = index
	displays[highlightedActorIndex].SetHighlight(true)
