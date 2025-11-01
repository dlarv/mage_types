@tool
extends Node3D

signal battle_sprite_added(actor: BattleActor, sprite: _BattleSprite)
signal selected(actor: BattleActor)
signal status_effect_icon_pressed(effect: StatusEffect)

const _BattleSprite := preload("res://src/battle_system/gui/BattleSprite.gd")
const DefaultBattleSprite := preload("res://data/monster_battle_sprites/placeholder.tscn")
const _BattleActorDisplay := preload("res://src/battle_system/gui/components/BattleActorDisplay.gd")
const BattleActorDisplay := preload("res://src/battle_system/gui/components/battle_actor_display.tscn")

@export var ally_container: Container
@export var opponent_container: Container

var displays: Array[_BattleActorDisplay] = []
var sprites: Array[_BattleSprite] = []
var actors: Dictionary[BattleActor, TeamDisplayActor] = {}

var _highlighted_actor_index: int = 0
var _allow_selecting_targets := false
var _selected_target: TeamDisplayActor = null


func _unhandled_key_input(event: InputEvent) -> void:
	if not _allow_selecting_targets: 
		if _selected_target: 
			_selected_target.hover(true)
		return
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		_selected_target.opposite.hover(true)
	elif event.is_action_pressed("ui_right"):
		_selected_target.next.hover(true)
	elif event.is_action_pressed("ui_left"):
		_selected_target.prev.hover(true)
	elif event.is_action_pressed("ui_select"):
		_selected_target.select()


func _on_actor_hovered(actor: TeamDisplayActor) -> void:
	_selected_target.hover_no_signal(false)
	actor.hover_no_signal(true)
	_selected_target = actor


func setup(allies: Array[BattleActor], enemies: Array[BattleActor]) -> void:
	var headAlly: TeamDisplayActor = add_display(allies[0], true)
	var headEnemy: TeamDisplayActor = add_display(enemies[0], false)
	headAlly.set_opposite(headEnemy)
	headEnemy.set_opposite(headAlly)

	var prev := headAlly
	for ally: BattleActor in allies.slice(1):
		var disp := add_display(ally, true)
		disp.set_opposite(headEnemy)
		disp.set_prev(prev)
		prev.set_next(disp)
		prev = disp
	# Displays will loop around
	prev.set_next(headAlly)
	headAlly.set_prev(prev.next)

	prev = headEnemy
	for enemy: BattleActor in enemies.slice(1):
		var disp := add_display(enemy, false)
		disp.set_opposite(headEnemy)
		prev.set_next(disp)
		prev = disp
	# Displays will loop around
	prev.set_next(headEnemy)
	headEnemy.set_prev(prev.next)


func add_display(actor: BattleActor, isAlly: bool) -> TeamDisplayActor:
	var sprite: _BattleSprite 
	if actor.sprite_path == null:
		sprite = DefaultBattleSprite.instantiate()
	else:
		sprite = actor.sprite_path.instantiate()

	sprite.setup(actor, not isAlly)
	sprites.append(sprite)

	actor.element_changed.connect(sprite.set_element)
	sprite.status_effect_icon_pressed.connect(func(effect: StatusEffect) -> void: 
		status_effect_icon_pressed.emit(effect)
	)
	sprite.selected.connect(func(selectedActor: BattleActor) -> void:
		selected.emit(selectedActor)
		for d: Node in sprites:
			_allow_selecting_targets = false
			_selected_target = null 
			d.disable_selection()
			if not Settings.enable_transmutation_hints: continue
			d.disable_transmutation_hint())
	sprite.position.x += len(sprites) * 3

	var display := BattleActorDisplay.instantiate()
	display.setup(actor)
	displays.append(display)
	
	if isAlly:
		ally_container.add_child(display)
		$AllyParent.add_child(sprite)
		sprite.position.x += $AllyParent.get_child_count() * 1.5
	else:
		opponent_container.add_child(display)
		$OpponentParent.add_child(sprite)
		sprite.position.x += $OpponentParent.get_child_count() * 1.5
		sprite.rotation_degrees.y = 180

	var disp := TeamDisplayActor.new(sprite, display, isAlly)
	actors[actor] = disp
	disp.hovered.connect(_on_actor_hovered)

	battle_sprite_added.emit(actor, sprite)
	return disp 


func get_display(actor: Variant) -> _BattleActorDisplay:
	return actors[actor].display


func get_sprite(actor: Variant) -> Node3D:
	return actors[actor].sprite


## Allow the player to highlight and select one of the contained BattleActorDisplays.
func select_target(user: BattleActor, action: _BattleAction) -> void:
	var targets: Array

	match action.target:
		_BattleAction.TargetType.SELF:
			targets = [ user ]
			var sprite := get_sprite(user)
			sprite.enable_selection(Color.GREEN)
			_selected_target = actors[user]

			if Settings.enable_transmutation_hints:
				sprite.enable_transmutation_hint(action)
			
		_BattleAction.TargetType.ALLY:
			_enable_target_selection(Color.GREEN, action)
			_selected_target = actors[user].next
			
		_BattleAction.TargetType.ENEMY:
			_enable_target_selection(Color.RED, action)
			_selected_target = actors[user].opposite

		_BattleAction.TargetType.ANY:
			_enable_target_selection(Color.BLUE, action)
			_selected_target = actors[user].next

		# These cases are handled by caller.
		# _BattleAction.TargetType.ALLIES:
		# _BattleAction.TargetType.ENEMIES:
		# _BattleAction.TargetType.ALL:
		# _BattleAction.TargetType.RANDOM:
	
	_selected_target.hover(true)


func _enable_target_selection(highlightColor: Color, action: _BattleAction) -> void:
	_allow_selecting_targets = true
	for sprite: Node in sprites:
		sprite.enable_selection(highlightColor)

		if Settings.enable_transmutation_hints:
			sprite.enable_transmutation_hint(action)


func cancel_target_selection() -> void:
	_allow_selecting_targets = false 
	_selected_target = null

	selected.emit(null)
	for d in sprites:
		d.disable_selection()

		if Settings.enable_transmutation_hints:
			d.disable_transmutation_hint()


func enable_transmutation_hint(target: BattleActor, action: _BattleAction) -> void:
	if not Settings.enable_transmutation_hints: return
	get_sprite(target).enable_transmutation_hint(action)


# Highlight the display of the currently active actor.
func highlight(index: int) -> void:
	sprites[_highlighted_actor_index].set_highlight(false)
	_highlighted_actor_index = index
	sprites[_highlighted_actor_index].set_highlight(true)


## Show intentions particle effect.
func show_enemy_intentions(val: bool) -> void:
	for actor: TeamDisplayActor in actors.values():
		if not actor.is_ally:
			actor.sprite.show_intentions(val)


class TeamDisplayActor:
	signal hovered(disp: TeamDisplayActor)

	var sprite: Node
	var display: Node
	var is_ally: bool
	var opposite: TeamDisplayActor = null
	var next: TeamDisplayActor = null
	var prev:  TeamDisplayActor = null

	func _init(sprite: Node, display: Node, isAlly: bool) -> void:
		self.sprite = sprite
		self.display = display
		self.is_ally = isAlly

		sprite.hovered.connect(func(actor: BattleActor) -> void: hovered.emit(self))


	func set_opposite(disp: TeamDisplayActor) -> void:
		opposite = disp


	func set_next(disp: TeamDisplayActor) -> void:
		next = disp


	func set_prev(disp: TeamDisplayActor) -> void:
		prev = disp


	func hover_no_signal(val: bool) -> void:
		sprite.hover_no_signal(val)


	func hover(val: bool) -> void:
		sprite.hover(val)


	func select() -> void:
		sprite.select()
