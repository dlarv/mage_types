extends Control

signal setup_finished(team1: Array, team2: Array)

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
		
var _characters = []
var _attacks = []


func _ready():
	_populate_element_option_buttons()
	_connect_stat_spinboxes()
	_button_group = ButtonGroup.new()
	_button_group.pressed.connect(_on_character_selected)
	load_character_button.pressed.connect(func(): 
		file_popup.set_current_dir("res://data/characters")
		file_popup.popup())
		
	load_attack_button.pressed.connect(func(): 
		file_popup.set_current_dir("res://data/attacks")
		file_popup.popup())
	
	load_default_teams()

func load_default_teams():
	_on_file_dialog_file_selected("res://data/characters/big_man.tres")
	_on_create_character_button_pressed()
	_on_file_dialog_file_selected("res://data/characters/double_double.tres")
	#_on_file_dialog_file_selected("res://data/characters/sponge_man.tres")
	_on_create_character_button_pressed()
	character_scroller.get_child(1).set_team_index(1)

func _populate_element_option_buttons():
	element1_input.clear()
	element2_input.clear()
	attack_element_input.clear()
	
	element2_input.add_item("None")
	
	for el in MatchupManager.elements:
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
	hp_input.max_value = BattleActor.MAX_STAT
	attack_input.value_changed.connect(lambda.bind("attack"))
	attack_input.max_value = BattleActor.MAX_STAT
	defense_input.value_changed.connect(lambda.bind("defense"))
	defense_input.max_value = BattleActor.MAX_STAT
	speed_input.value_changed.connect(lambda.bind("speed"))
	speed_input.max_value = BattleActor.MAX_STAT

func _on_create_attack_button_pressed():
	var name = attack_name_input.text
	if name.is_empty(): 
		alert_popup.get_label().text = "Character must be given a name."
		alert_popup.show()
		return
		
	attack_name_input.text = ""
	
	var power = power_input.value
	power_input.value = 10
	
	var range = range_input.get_selected_id()
	range_input.select(0)
	
	var element_index = attack_element_input.get_selected_id()
	var element = MatchupManager.elements[element_index]
	attack_element_input.select(0)
	
	var item = AttackListItem.instantiate()
	var attack = Attack.new()
	attack.create(name, element, power, range)
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
	var element1 = MatchupManager.elements[index]
	
	index = element2_input.get_selected_id()
	element2_input.select(0)
	var element2 
	if index != 0:
		element2 = MatchupManager.elements[index - 1]
	else:
		element2 = null
	
	var actor = BattleActor.create(actor_name, element1, element2, _attacks, _stats)
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
	
	setup_finished.emit(team1, team2)


func _on_file_dialog_file_selected(path):
	var actor = ResourceLoader.load(path)
	
	# Check if player is trying to load an attack or character
	if actor is Attack:
		attack_element_input.select(MatchupManager.get_index_from_name(actor.element.type_name))
		attack_name_input.text = actor.attack_name
		power_input.value = actor.power
		range_input.select(actor.range)
		return
	
	name_input.text = actor.actor_name
	element1_input.select(MatchupManager.get_index_from_name(actor.element1))
	_stats = actor.get_stats()
	
	# Set 2nd element, if applicable
	var e2 = MatchupManager.get_index_from_name(actor.element2)
	if e2 != -1:
		element2_input.select(e2 + 1)
	else:
		element2_input.select(0)
	
	# Set attacks
	for attack in actor.attacks:
		attack_element_input.select(MatchupManager.get_index_from_name(attack.element.type_name))
		attack_name_input.text = attack.attack_name
		power_input.value = attack.power
		range_input.select(attack.range)
		_on_create_attack_button_pressed()
