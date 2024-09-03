extends Control

signal setup_finished(team1: Array, items: Array, team2: Array, ai)

@export var AttackListItem: PackedScene
@export var CharacterListItem: PackedScene
@export var alert_popup: AcceptDialog

@export_category("Character Creation")
@export var name_input: LineEdit
@export var element1_input: OptionButton
@export var element2_input: OptionButton
@export var load_character_button: Button
@export var file_popup: FileDialog

@export_category("Stat Input")
@export var stats_header: Label
@export var hp_input: SpinBox
@export var attack_input: SpinBox
@export var defense_input: SpinBox
@export var speed_input: SpinBox

@export_category("Attack Input")
@export var attack_element_input: OptionButton
@export var attack_name_input: LineEdit
@export var power_input: SpinBox
@export var range_input: OptionButton
@export var attack_scroller: VBoxContainer
@export var load_attack_button: Button

@export_category("Items")
@export var item_name_input: LineEdit
@export var load_item_button: Button

@export_category("Character Display")
@export var character_scroller: VBoxContainer
@export var character_display: Control
var _button_group: ButtonGroup
var _displayed_character: Control

var _stats = {}:
	set(val):
		if val == {}:
			for key in ["hp", "attack", "defense", "speed"]:
				_stats[key] = 1
			stats_header.text = "\nStats: 4"
			return
		_stats = val
		var h = val.get("hp")
		var i = val.get("hp", hp_input.value)
		hp_input.value = val.get("hp", hp_input.value)
		attack_input.value = val.get("attack", attack_input.value)
		defense_input.value = val.get("defense", defense_input.value)
		speed_input.value = val.get("speed", speed_input.value)
		
var _attack_description = ""
var _item_description = ""
var _characters = []
var _attacks = []
var _items = []
var ai

func _ready():
	# _populate_element_option_buttons()
	_connect_stat_spinboxes()
	_button_group = ButtonGroup.new()
	_button_group.pressed.connect(_on_character_selected)
	load_character_button.pressed.connect(func(): 
		file_popup.set_current_dir("res://data/battle_system/battle_actors")
		file_popup.popup())
		
	load_attack_button.pressed.connect(func(): 
		file_popup.set_current_dir("res://data/battle_system/battle_actions/attacks")
		file_popup.popup())
	
	load_item_button.pressed.connect(func():
		file_popup.set_current_dir("res://data/battle_system/battle_actions/items")
		file_popup.popup())

	load_default_teams()

func _unhandled_input(input):
	if input.is_action_pressed("ui_accept"):
		_on_start_battle_button_pressed()

func load_default_teams():
	_on_file_dialog_file_selected("res://data/battle_system/battle_actors/basic_battle_actor.tscn")
	_on_create_character_button_pressed()
	_on_file_dialog_file_selected("res://data/battle_system/battle_actors/basic_battle_actor.tscn")
	_on_create_character_button_pressed()
	_on_file_dialog_file_selected("res://data/battle_system/battle_actors/basic_battle_actor.tscn")
	#_on_file_dialog_file_selected("res://data/characters/sponge_man.tres")
	_on_create_character_button_pressed()
	character_scroller.get_child(1).set_team_index(1)

func _populate_element_option_buttons():
	element1_input.clear()
	element2_input.clear()
	attack_element_input.clear()
	
	for el in ElementManager.Elements:
		var texture = GradientTexture2D.new()
		var gradient = Gradient.new()
		gradient.set_color(0, el.color)
		gradient.set_color(1, el.color)
		texture.gradient = gradient
		element1_input.add_icon_item(texture, el.type_name)
		element2_input.add_icon_item(texture, el.type_name)
		attack_element_input.add_icon_item(texture, el.type_name)


func _connect_stat_spinboxes():
	_stats = {}
	
	var lambda = func(val: float, key: String):
		_stats[key] = val
		var total = 0
		for value in _stats.values():
			total += value
		stats_header.text = "\nStats: %d" % total
	
	hp_input.value_changed.connect(lambda.bind("hp"))
	hp_input.max_value = BattleActor.GetMaxStat()
	attack_input.value_changed.connect(lambda.bind("attack"))
	attack_input.max_value = BattleActor.GetMaxStat()
	defense_input.value_changed.connect(lambda.bind("defense"))
	defense_input.max_value = BattleActor.GetMaxStat()
	speed_input.value_changed.connect(lambda.bind("speed"))
	speed_input.max_value = BattleActor.GetMaxStat()

func _on_create_attack_button_pressed():
	var name = attack_name_input.text
	if name.is_empty(): 
		alert_popup.get_label().text = "Character must be given a name."
		alert_popup.show()
		return
		
	attack_name_input.text = ""
	
	var power = power_input.value
	power_input.value = 10
	
	var range_value = range_input.get_selected_id()
	range_input.select(0)
	
	var element_index = attack_element_input.get_selected_id()
	var element = ElementManager.Elements[element_index]
	attack_element_input.select(0)
	
	var item = AttackListItem.instantiate()
	var attack = Attack.Create(name, element, power, range_value, _attack_description)
	_attacks.append(attack)
	var button = item.create(attack)
	attack_scroller.add_child(item)
	button.pressed.connect(_on_remove_attack_button_pressed.bind(item, len(_attacks) - 1))


func _on_remove_attack_button_pressed(child: Control, index: int):
	attack_scroller.remove_child(child)
	_attacks.remove_at(index)


func _on_remove_character_button_pressed(child: Control, index: int):
	character_scroller.remove_child(child)
	_characters.remove_at(index)
	
	if _displayed_character == child:
		character_display.clear()


func _on_create_character_button_pressed():
	var actor_name = name_input.text
	if actor_name.is_empty(): 
		alert_popup.get_label().text = "Character must be given a name."
		alert_popup.show()
		return
	name_input.text = ""
	
	var index = element1_input.get_selected_id()
	element1_input.select(0)
	var element1 = ElementManager.Elements[index]
	
	index = element2_input.get_selected_id()
	element2_input.select(0)
	var element2 
	element2 = ElementManager.Elements[index]
	
	var actor = BattleActor.Create(actor_name, element1, element2, _attacks, _stats)
	_characters.append(actor)
	
	for attack in attack_scroller.get_children():
		attack_scroller.remove_child(attack)
	_attacks = []
	_stats = {}

	hp_input.value = 1
	attack_input.value = 1
	defense_input.value = 1
	speed_input.value = 1
	
	var item = CharacterListItem.instantiate()
	character_scroller.add_child(item)
	var del_button = item.create(actor)
	del_button.pressed.connect( \
		_on_remove_character_button_pressed.bind( \
			item, \
			len(_characters) - 1))
	var selector: CheckBox = item.selector
	selector.button_group = _button_group

func _on_create_item_button_pressed():
	var item_name = item_name_input.text
	if item_name.is_empty(): 
		alert_popup.get_label().text = "Item must be given a name."
		alert_popup.show()
		return

	var item = BattleItem.Create(item_name, _item_description)
	_items.append(item)

func _on_character_selected(button: Button):
	var control = button.get_parent().get_parent()
	var character = control.character
	character_display.display(character)
	_displayed_character = control
	

func _on_start_battle_button_pressed():
	var team1 = []
	var team2 = []
	
	for actor in character_scroller.get_children():
		var index = actor.get_team_index()
		if index == 0:
			team1.append(actor.character)
		else:
			team2.append(actor.character)
	
	if len(team1) == 0 or len(team2) == 0:
		alert_popup.get_label().text = "Each team must have 1 or more characters"
		alert_popup.show()
		return
	
	setup_finished.emit(team1, _items, team2, ai)


func _on_file_dialog_file_selected(path):
	var actor = ResourceLoader.load(path)
	
	# Check if player is trying to load an attack or character
	if actor is Attack:
		attack_element_input.select(ElementManager.GetIndexFromName(actor.Element.Name))
		attack_name_input.text = actor.Name
		power_input.value = actor.Power
		range_input.select(actor.Range)
		_attack_description = actor.Details
		return
	if actor is BattleItem:
		_item_description = actor.Details
		item_name_input.text = actor.Name
		return

	if actor is PackedScene:
		actor = actor.instantiate()
	
	name_input.text = actor.ActorName
	element1_input.select(ElementManager.GetIndexFromName(actor.Element1.Name))
	element2_input.select(ElementManager.GetIndexFromName(actor.Element2.Name))

	_stats = {
		"hp": actor.Hp,
		"attack": actor.MeleeAttack,
		"defense": actor.MeleeDefense,
		"speed": actor.Speed
	}
	
	# Set attacks
	for attack in actor.Attacks:
		attack_element_input.select(ElementManager.GetIndexFromName(attack.Element.Name))
		attack_name_input.text = attack.Name
		power_input.value = attack.Power
		_attack_description = attack.Details
		_on_create_attack_button_pressed()
		range_input.select(attack.Range)
