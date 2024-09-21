@tool
extends Control 
class_name CharacterScreen 

@export
var Actor: BattleActor:
	get:
		return _actor; 
	set(value):
		SetActor(value); 

var _actor;
@export
var AllowStatEditing : bool:
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

func _Ready() -> void:
	SetActor(Actor);
	if not Engine.is_editor_hint():
		Actor.ElementChanged.connect(func(id, element):
			if id == 0: elementIcon1.Element = element
			else: elementIcon2.Element = element)

func SetActor(actor: BattleActor) -> void:
	if actor == null: return;
	_actor = actor;

	if statItemsScroller != null: 
		for item in statItemsScroller.get_children():
			item.ChangeValue(actor);

	if nameLabel != null:
		nameLabel.text = actor.ActorName;
	
	if elementIcon1 != null:
		elementIcon1.Element = actor.Element1;
	
	if elementIcon2 != null:
		elementIcon2.Element = actor.Element2;
	
	if biasIcon != null:
		biasIcon.Element = actor.ElementalBias;

func OnStatModified(name: String, amount: int) -> void:
	Actor.SetStat(name, amount);
