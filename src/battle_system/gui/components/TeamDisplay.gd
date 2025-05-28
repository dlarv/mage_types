@tool
extends Node3D
class_name TeamDisplay 

signal selected(actor)
signal status_effect_icon_pressed(effect)

@export var BattleSprite: PackedScene
@export var display_prefab: PackedScene 

var length: int: 
	get: return len(displays)

# BattleActorDisplay[]
var displays := []
# BattleSprite[]
var sprites := []

var actors := {}

var highlightedActorIndex: int = 0

func add_display(actor: BattleActor, isAlly: bool) -> BattleActorDisplay:
	var sprite = BattleSprite.instantiate()
	sprite.setup(actor, not isAlly)
	sprites.append(sprite)

	actor.element_changed.connect(sprite.set_element)
	sprite.status_effect_icon_pressed.connect(func(effect): status_effect_icon_pressed.emit(effect))
	sprite.selected.connect(func(a):
		selected.emit(a)
		for d in sprites:
			d.disable_selection()
			if not Settings.enable_transmutation_hints: continue
			d.disable_transmutation_hint())
	sprite.position.x += len(sprites) * 3
	# sprite.position.z += len(sprites) * 1.5

	var display = display_prefab.instantiate()
	display.setup(actor)
	displays.append(display)
	
	if isAlly:
		%AllyVBox.add_child(display)
		$AllyParent.add_child(sprite)
		sprite.position.x += $AllyParent.get_child_count() * 1.5
	else:
		%OpponentVBox.add_child(display)
		$OpponentParent.add_child(sprite)
		sprite.position.x += $OpponentParent.get_child_count() * 1.5

	actors[actor] = TeamDisplayActor.new(sprite, display, isAlly)
	return display

func get_display(actor: Variant) -> BattleActorDisplay:
	return actors[actor].display

func get_sprite(actor: Variant) -> Node3D:
	return actors[actor].sprite

## Allow the player to highlight and select one of the contained BattleActorDisplays.
func select_target(user: BattleActor, action: _BattleAction) -> void:
	var targets: Array

	match action.target:
		_BattleAction.TargetType.SELF:
			targets = [ user ]
			select_specific_target(false, action, user)
			
		_BattleAction.TargetType.ALLY:
			_enable_target_selection(Color.GREEN, action)
			
		_BattleAction.TargetType.ENEMY:
			_enable_target_selection(Color.RED, action)

		_BattleAction.TargetType.ANY:
			_enable_target_selection(Color.BLUE, action)

		# These cases are handled by caller.
		# _BattleAction.TargetType.ALLIES:
		# _BattleAction.TargetType.ENEMIES:
		# _BattleAction.TargetType.ALL:
		# _BattleAction.TargetType.RANDOM:

func _enable_target_selection(highlightColor: Color, action: _BattleAction):
	for sprite in sprites:
		sprite.enable_selection(highlightColor)

		if Settings.enable_transmutation_hints:
			sprite.enable_transmutation_hint(action)

func select_specific_target(isAttack: bool, action: _BattleAction, actor: BattleActor) -> void:
	var highlight =  Color.RED if isAttack else Color.GREEN
	var sprite := get_sprite(actor)
	sprite.enable_selection(highlight)

	if Settings.enable_transmutation_hints:
		sprite.enable_transmutation_hint(action)

func has_actor(actor: BattleActor) -> bool:
	return actor in actors.keys()


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
	for actor in actors.values():
		if not actor.is_ally:
			actor.sprite.show_intentions(val)

class TeamDisplayActor:
	var sprite: Node
	var display: Node
	var is_ally: bool

	func _init(sprite, display, isAlly):
		self.sprite = sprite
		self.display = display
		self.is_ally = isAlly
