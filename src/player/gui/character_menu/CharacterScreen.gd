@tool
extends Control 
class_name CharacterScreen 

@export
var actor: BattleActor:
	get:
		return _actor; 
	set(value):
		set_actor(value); 

var _actor;
@export
var allow_stat_editing : bool:
	get:
		return _allowStatEditing;
	set(value):
		_allowStatEditing = value;
		if statItemsScroller == null: return;
		for item in statItemsScroller.get_children():
			item.editable = value;

var _allowStatEditing = true;
@export
var nameLabel: Label ;
@export
var elementIcon1: ElementIcon ;
@export
var elementIcon2: ElementIcon ;
@export
var biasIcon: ElementIcon ;

@export
var statItemsScroller: VBoxContainer ;

func _ready() -> void:
	set_actor(actor);
	if not Engine.is_editor_hint():
		actor.element_changed.connect(func(id, element):
			if id == 0: elementIcon1.element = element
			else: elementIcon2.element = element)

func set_actor(actor: BattleActor) -> void:
	if actor == null: return;
	_actor = actor;

	if statItemsScroller != null: 
		for item in statItemsScroller.get_children():
			item.change_value(actor);

	if nameLabel != null:
		nameLabel.text = actor.name;
	
	if elementIcon1 != null:
		elementIcon1.element = actor.element1;
	
	if elementIcon2 != null:
		elementIcon2.element = actor.element2;
	
	if biasIcon != null:
		biasIcon.element = actor.elemental_bias;

func on_stat_modified(name: String, amount: int) -> void:
	actor.set_stat(name, amount);
