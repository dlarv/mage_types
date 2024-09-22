extends VBoxContainer

signal attack_created(attack)
signal alert(msg: String)
signal open_file(path: String)

@export var AttackListItem: PackedScene

@export var attack_element_input: OptionButton
@export var attack_name_input: LineEdit
@export var power_input: SpinBox
@export var range_input: OptionButton
@export var target_input: OptionButton
@export var attack_scroller: VBoxContainer
@export var load_attack_button: Button

var attack: Attack
var attacks = []

func _ready():
	attack = Attack.new()

	load_attack_button.pressed.connect(func():
		open_file.emit("res://data/battle_system/battle_actions/attacks"))

	attack_element_input.item_selected.connect(func(index):
		attack.element = ElementManager.elements[index])
	attack_name_input.text_changed.connect(func(text):
		attack.name = text)
	# power_input.value_changed.connect(func(val):
	# 	attack.Power = val)
	range_input.item_selected.connect(func(index):
		attack.attack_range = index)
	target_input.item_selected.connect(func(index):
		attack.target = index)

func _on_create_button_pressed():
	var item = AttackListItem.instantiate()
	var button = item.create(attack)
	attack_scroller.add_child(item)
	button.pressed.connect(_on_remove_attack_button_pressed.bind(item, len(attacks) - 1))

	attack_created.emit(attack)
	attacks.append(attack)
	clear()

func _on_remove_attack_button_pressed(child, index):
	attack_scroller.remove_child(child)
	attacks.remove_at(index)

func clear():
	attack = Attack.new()
	attack_element_input.select(0)
	attack_name_input.text = ""
	# power_input.value = attack.Power
	range_input.select(0)
	target_input.select(3)

func clear_scroller():
	attacks = []
	for attack in attack_scroller.get_children():
		attack_scroller.remove_child(attack)

func set_attack(attack):
	self.attack = attack
	attack_element_input.select(ElementManager.get_index_from_name(attack.element.name))
	attack_name_input.text = attack.name
	# power_input.value = attack.Power
	range_input.select(attack.attack_range)
	target_input.select(attack.target)

func add_attacks(attacks):
	self.attacks = attacks

	for attack in attacks:
		var item = AttackListItem.instantiate()
		var button = item.create(attack)
		button.pressed.connect(_on_remove_attack_button_pressed.bind(item, len(attacks) - 1))
		attack_scroller.add_child(item)

