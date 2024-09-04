extends MarginContainer

signal open_file(path: String)
signal alert(msg: String)
signal character_created(actor)

@export var CharacterListItem: PackedScene

@export_category("Character Creation")
@export var name_input: LineEdit
@export var element1_input: OptionButton
@export var element2_input: OptionButton
@export var load_character_button: Button

@export_category("Stat Input")
@export var hp_input: SpinBox
@export var attack_input: SpinBox
@export var defense_input: SpinBox
@export var speed_input: SpinBox

@export_category("Attacks")
@export var attack_creator: Control

var character

func _ready():
	# Connect signals.
	character = BattleActor.new()
	load_character_button.pressed.connect(func():
		open_file.emit("res://data/battle_system/battle_actors"))

	attack_creator.open_file.connect(func(path):
		open_file.emit(path))

	attack_creator.alert.connect(func(msg):
		alert.emit(msg))
	
	# Initialize controls.
	name_input.text_changed.connect(func(text):
		character.ActorName = text)
	element1_input.item_selected.connect(func(index):
		character.Element1 = ElementManager.Elements[index])
	element2_input.item_selected.connect(func(index):
		character.Element2 = ElementManager.Elements[index])
	hp_input.value_changed.connect(func(value):
		character.SetStat("hp", value))
	attack_input.value_changed.connect(func(value):
		character.SetStat("attack", value))
	defense_input.value_changed.connect(func(value):
		character.SetStat("defense", value))
	speed_input.value_changed.connect(func(value):
		character.SetStat("speed", value))


func set_character(actor):
	## Receive actor from parent and populate its values.
	character = actor

	name_input.text = actor.ActorName
	element1_input.select(ElementManager.GetIndexFromName(actor.Element1.Name))
	element2_input.select(ElementManager.GetIndexFromName(actor.Element2.Name))
	hp_input.value = actor.GetStat("hp")
	attack_input.value = actor.GetStat("attack")
	defense_input.value = actor.GetStat("defense")
	speed_input.value = actor.GetStat("speed")

	attack_creator.add_attacks(actor.Attacks)

func set_attack(attack):
	attack_creator.set_attack(attack)

func _on_create_button_pressed():
	var _attacks = attack_creator.attacks
	character.Attacks = _attacks

	character_created.emit(character)
	clear()
	attack_creator.clear_scroller()
	character = BattleActor.new()

func clear():
	name_input.text = ""
	element1_input.select(0)
	element2_input.select(0)
	hp_input.value = 0
	attack_input.value = 0
	defense_input.value = 0 
	speed_input.value = 0
