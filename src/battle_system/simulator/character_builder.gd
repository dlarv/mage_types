extends Control

signal setup_finished(team1: Array, items: Array, team2: Array, ai)

@export var CharacterListItem: PackedScene
@export var alert_popup: AcceptDialog
@export var character_creator: Control
@export var file_popup: FileDialog
@export var default_ally_count: int

@export_category("Items")
@export var item_name_input: LineEdit
@export var load_item_button: Button

@export_category("Character Display")
@export var character_scroller: VBoxContainer
@export var character_display: Control
var _button_group: ButtonGroup
var _displayed_character: Control

var _item_description: String

var _characters := []
var _items := []
var ai: OpponentController

func _ready():
	print("start")
	_button_group = ButtonGroup.new()
	_button_group.pressed.connect(_on_character_selected)

	character_creator.alert.connect(func(msg):
		alert_popup.get_label().text = msg
		alert_popup.show())

	character_creator.open_file.connect(func(path):
		file_popup.set_current_dir(path)
		file_popup.popup())

	print("loading teams")
	load_default_teams()
	print("teams loaded")

func load_default_teams():
	var actor = ResourceLoader.load("res://data/battle_system/battle_actors/basic_battle_actor.tres")
	_on_character_created(actor)
	character_scroller.get_child(0).set_team_index(1)

	for i in range(default_ally_count):
		actor = ResourceLoader.load("res://data/battle_system/battle_actors/basic_battle_actor.tres")
		_on_character_created(actor)

	actor = ResourceLoader.load("res://data/battle_system/battle_actors/clown.tres")
	_on_character_created(actor)

func _unhandled_input(input):
	if visible && input.is_action_pressed("ui_accept"):
		_on_start_battle_button_pressed()


func _on_remove_character_button_pressed(child: Control, index: int):
	character_scroller.remove_child(child)
	_characters.remove_at(index)
	
	if _displayed_character == child:
		character_display.clear()

func _on_create_item_button_pressed():
	var item_name = item_name_input.text
	if item_name.is_empty(): 
		alert_popup.get_label().text = "Item must be given a name."
		alert_popup.show()
		return

	var item = BattleItem.create(item_name, _item_description)
	_items.append(item)

func _on_character_selected(button: Button):
	var control = button.get_parent().get_parent()
	var character = control.character
	character_display.display(character)
	_displayed_character = control
	

func _on_file_dialog_file_selected(path):
	var actor = ResourceLoader.load(path)
	
	# Check if player is trying to load an attack or character
	if actor is Attack:
		character_creator.set_attack(actor)
		return
	if actor is BattleItem:
		_item_description = actor.details
		item_name_input.text = actor.name
		return

	if actor is PackedScene:
		actor = actor.instantiate()
	
	character_creator.set_character(actor)

func _on_character_created(actor: BattleActor):
	_characters.append(actor)

	var item = CharacterListItem.instantiate()
	var button = item.create(actor)
	button.pressed.connect(_on_remove_character_button_pressed.bind(item, len(_characters) - 1))
	character_scroller.add_child(item)

	var selector: CheckBox = item.selector
	selector.button_group = _button_group

func _on_start_battle_button_pressed():
	var team1 = []
	var team2 = []
	
	for actor in character_scroller.get_children():
		var index = actor.get_team_index()
		# Reset character's health, if a game was already played.
		actor.character.current_hp = actor.character.hp
		actor.character.use_gradient_sprite()
		if index == 0:
			team1.append(actor.character)
		else:
			team2.append(actor.character)
	
	if len(team1) == 0 or len(team2) == 0:
		alert_popup.get_label().text = "Each team must have 1 or more characters"
		alert_popup.show()
		return
	
	setup_finished.emit(team1, _items, team2, ai)

