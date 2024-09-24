@tool
extends Control 
class_name CharacterScreen 

@export
var actor: BattleActor:
	get:
		return actor 
	set(value):
		actor = value
		init_actor() 
@export
var movepool: Movepool
@export
var allow_stat_editing : bool:
	get:
		return _allowStatEditing
	set(value):
		_allowStatEditing = value
		if statItemsScroller == null: return
		for item in statItemsScroller.get_children():
			item.editable = value

var _allowStatEditing = true
@export
var nameLabel: Label 
@export
var elementIcon1: ElementIcon 
@export
var elementIcon2: ElementIcon 
@export
var biasIcon: ElementIcon 

@export
var statItemsScroller: VBoxContainer 
@export
var spells_menu: Control

func _ready() -> void:
	init_actor()
	if not Engine.is_editor_hint():
		actor.element_changed.connect(func(id, element):
			if id == 0: elementIcon1.element = element
			else: elementIcon2.element = element)

func init_actor() -> void:
	if actor == null: return

	if statItemsScroller != null: 
		for item in statItemsScroller.get_children():
			item.change_value(actor)

	if nameLabel != null:
		nameLabel.text = actor.name
	
	if elementIcon1 != null:
		elementIcon1.element = actor.element1
	
	if elementIcon2 != null:
		elementIcon2.element = actor.element2
	
	if biasIcon != null:
		biasIcon.element = actor.elemental_bias
	
	if spells_menu != null:
		spells_menu.setup(actor, movepool)

func on_stat_modified(name: String, amount: int) -> void:
	actor.set_stat(name, amount)
