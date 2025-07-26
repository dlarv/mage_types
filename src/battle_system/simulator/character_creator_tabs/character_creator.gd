extends MarginContainer
@warning_ignore_start("untyped_declaration")

signal open_file(path: String)
signal alert(msg: String)
signal character_created(actor: BattleActor)

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
		character.name = text)
	element1_input.item_selected.connect(func(index):
		character.element1 = ElementManager.elements[index])
	element2_input.item_selected.connect(func(index):
		character.element2 = ElementManager.elements[index])
	hp_input.value_changed.connect(func(value):
		character.set_stat("hp", value))
	attack_input.value_changed.connect(func(value):
		character.set_stat("attack", value))
	defense_input.value_changed.connect(func(value):
		character.set_stat("defense", value))
	speed_input.value_changed.connect(func(value):
		character.set_stat("speed", value))


func set_character(actor):
	## Receive actor from parent and populate its values.
	character = actor

	name_input.text = actor.name
	element1_input.select(ElementManager.get_index_from_name(actor.element1.name))
	element2_input.select(ElementManager.get_index_from_name(actor.element2.name))
	hp_input.value = actor.get_stat("hp")
	attack_input.value = actor.get_stat("attack")
	defense_input.value = actor.get_stat("defense")
	speed_input.value = actor.get_stat("speed")

	attack_creator.add_attacks(actor.attacks)

func set_attack(attack):
	attack_creator.set_attack(attack)

func _on_create_button_pressed():
	var _attacks = attack_creator.attacks
	character.attacks = _attacks

	character_created.emit(character)
	clear()
	attack_creator.clear_scroller()
	character = BattleActor.new()

func clear():
	name_input.text = ""
	element1_input.select(0)
	element2_input.select(0)
	hp_input.value = 100
	attack_input.value = 100
	defense_input.value = 100 
	speed_input.value = 100
