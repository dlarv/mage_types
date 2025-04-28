extends Control

signal open_equipment_menu()
signal open_spell_menu(index: int)

@export var max_spell_slots := 4
var _actor: BattleActor
var _attacks: Array
var _open_mode := 0


func setup(actor: BattleActor) -> void:
	_actor = actor

	%Name_Label.text = actor.name
	_init_stats(actor)

	if not actor.alignment:
		%Bias_Label.hide()
		%Bias_ElementIcon.hide()
	else:
		%Bias_Label.show()
		%Bias_ElementIcon.show()
		%Bias_ElementIcon.element = actor.alignment
	
	%Primary.element = actor.element1
	%Secondary.element = actor.element2
	if not actor.element_changed.is_connected(_on_element_changed):
		actor.element_changed.connect(_on_element_changed)
	
	_attacks = []
	_attacks.resize(max_spell_slots)

	if not actor.spell_learned.is_connected(_set_attack):
		actor.spell_learned.connect(_set_attack)

	for child in %SpellScroller.get_children(): %SpellScroller.remove_child(child)
	for i in range(max_spell_slots):
		var button := Button.new()
		%SpellScroller.add_child(button)
		button.pressed.connect(_on_item_selected.bind(i))
		if i < len(actor.attacks):
			var attack := actor.attacks[i]
			_set_attack(attack, i)
		else:
			button.text = " "

	if not actor.equipment_equipped.is_connected(_set_equipment):
		actor.equipment_equipped.connect(_set_equipment)

	if not %Equipment_Button.pressed.is_connected(_on_item_selected.bind(-1)):
		%Equipment_Button.pressed.connect(_on_item_selected.bind(-1))
	if actor.equipment != null:
		%Equipment_Button.text = actor.equipment.name
	else:
		%Equipment_Button.text = " "


func _init_stats(actor: BattleActor) -> void:
	for child in %Stats_HBox.get_children():
		child.set_value(actor)

	for child in %Stats_Container.get_children():
		child.set_value(actor)


func _set_attack(attack: Attack, index: int) -> void:
	if index >= max_spell_slots:
		push_warning("CharacterScreen gui not set up for more than %d attacks. Tried to set attack #%d." 
				% [max_spell_slots, index])
	%SpellScroller.get_children()[index].text = attack.name
	_attacks[index] = attack


func _set_equipment(e: Equipment) -> void:
	if e: 
		%Equipment_Button.text = e.name
	else:
		%Equipment_Button.text = " "


func _on_element_changed(id: int, element: ElementalType) -> void:
	if id == 0:
		%Primary.element = element
	else:
		%Secondary.element = element


func _on_item_selected(item: Variant) -> void:
	%InfoDisplay.clear_message()
	_open_mode = item
	if item >= 0:
		if _attacks[item] == null:
			_on_replace_button_pressed()
			return
		%InfoDisplay.display_message_non_blocking(_attacks[item])
		%Control_HBox.show()
	elif _actor.equipment:
		%InfoDisplay.display_message_non_blocking(_actor.equipment)
		%Control_HBox.show()
	else:
		_on_replace_button_pressed()


func _on_cancel_button_pressed() -> void:
	%InfoDisplay.clear_message()

func _on_replace_button_pressed() -> void:
	if _open_mode < 0:
		open_equipment_menu.emit()
	else:
		open_spell_menu.emit(_open_mode)
