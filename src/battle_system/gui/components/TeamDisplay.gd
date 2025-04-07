@tool
extends Node3D
class_name TeamDisplay 

signal selected(actor)
signal status_effect_icon_pressed(effect)

@export var BattleSprite: PackedScene
@export var display_prefab: PackedScene 
@export var display_parent: VBoxContainer 
@export
var shift_right: bool = false: 
	set(value):
		shift_right = value
		if (display_parent == null): return
		if value:
			$CanvasLayer/MarginContainer.anchors_preset = Control.PRESET_TOP_RIGHT
		else:
			$CanvasLayer/MarginContainer.anchors_preset = Control.PRESET_TOP_LEFT

var length: int: 
	get: return len(displays)

# BattleActorDisplay[]
var displays := []
# BattleSprite[]
var sprites := []

var highlightedActorIndex: int = 0

func add_display(actor: BattleActor) -> BattleActorDisplay:
	var sprite = BattleSprite.instantiate()
	sprite.setup(actor, shift_right)
	sprites.append(sprite)

	actor.element_changed.connect(sprite.set_element)
	sprite.status_effect_icon_pressed.connect(func(effect): status_effect_icon_pressed.emit(effect))
	sprite.selected.connect(func(a):
		selected.emit(a)
		for d in sprites:
			d.disable_selection()
			if not Settings.enable_transmutation_hints: continue
			d.disable_transmutation_hint())
	add_child(sprite)
	sprite.position.x += len(sprites) * 3
	# sprite.position.z += len(sprites) * 1.5

	var display = display_prefab.instantiate()
	display.setup(actor)
	displays.append(display)
	
	display_parent.add_child(display)

	# display.status_effect_icon_pressed.connect(func(effect): status_effect_icon_pressed.emit(effect))

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

func get_sprite_from_index(index: int) -> Node3D:
	if index < len(sprites):
		return sprites[index]
	return null

func get_sprite(actor: Variant) -> Node3D:
	if(actor is int): return get_sprite_from_index(actor)
	for sprite in sprites:
		if sprite.actor == actor:
			return sprite
	return null

## Allow the player to highlight and select one of the contained BattleActorDisplays.
func select_target(isAttack: bool, action: _BattleAction) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN
	for sprite in sprites:
		sprite.enable_selection(highlight)

		if Settings.enable_transmutation_hints:
			sprite.enable_transmutation_hint(action)

func select_specific_target(isAttack: bool, action: _BattleAction, actor: BattleActor) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN
	var sprite := get_sprite(actor)
	sprite.enable_selection(highlight)

	if Settings.enable_transmutation_hints:
		sprite.enable_transmutation_hint(action)


func select_all_as_target(isAttack: bool, action: _BattleAction) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN

	if not Settings.enable_transmutation_hints: return 

	for sprite in sprites:
		sprite.enable_transmutation_hint(action)

func cancel_target_selection():
	selected.emit(null)
	for d in sprites:
		d.disable_selection()

		if Settings.enable_transmutation_hints:
			d.disable_transmutation_hint()

func enable_transmutation_hint(target: BattleActor, action: _BattleAction):
	if not Settings.enable_transmutation_hints: return
	get_sprite(target).enable_transmutation_hint(action)


# Highlight the display of the currently active actor.
func highlight(index: int) -> void:
	sprites[highlightedActorIndex].set_highlight(false)
	highlightedActorIndex = index
	sprites[highlightedActorIndex].set_highlight(true)

## Show intentions particle effect.
func show_intentions(val: bool) -> void:
	for sprite in sprites:
		sprite.show_intentions(val)
