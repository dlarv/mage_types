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
@export var movepool: Movepool
@export
var allow_stat_editing : bool:
	set(value):
		allow_stat_editing = value
		if _stat_items_scroller == null: return
		for item in _stat_items_scroller.get_children():
			item.editable = value

@export var _name_label: Label 
@export var _element_icon_1: ElementIcon 
@export var _element_icon_2: ElementIcon 
@export var _bias_icon: ElementIcon 

@export var _stat_items_scroller: VBoxContainer 
@export var _spells_menu: Control

func _ready() -> void:
	init_actor()
	if not Engine.is_editor_hint():
		actor.element_changed.connect(func(id, element):
			if id == 0: _element_icon_1.element = element
			else: _element_icon_2.element = element)

func init_actor() -> void:
	if actor == null: return

	if _stat_items_scroller != null: 
		for item in _stat_items_scroller.get_children():
			item.set_value(actor)

	if _name_label != null:
		_name_label.text = actor.name
	
	if _element_icon_1 != null:
		_element_icon_1.element = actor.element1
	
	if _element_icon_2 != null:
		_element_icon_2.element = actor.element2
	
	if _bias_icon != null:
		_bias_icon.element = actor.elemental_bias
	
	if _spells_menu != null:
		_spells_menu.setup(actor, movepool)

func _on_stat_modified(stat: String, amount: float) -> void:
	match stat:
		"MANA": 
			actor.mana = int(amount)
		"CURRENT_MANA":
			actor.current_mana = int(amount)
		"HP":
			actor.hp = int(amount)
		"CURRENT_HP":
			actor.current_hp = int(amount)
		_:
			var key = StatManager.Stat.find_key(stat)
			actor.set_stat(StatManager.Stat.get(stat), amount)
