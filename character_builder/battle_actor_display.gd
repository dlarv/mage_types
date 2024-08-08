extends Control

@export var AttackListItem: PackedScene

@export var name_display: Label
@export var element1_display: ColorRect
@export var element2_display: ColorRect
@export var stats_vbox: VBoxContainer
@export var attacks_scroller: VBoxContainer


func display(character: BattleActor.Fighter):
	clear()
	name_display.text = character.actor_name
	element1_display.color = character.primary_element.color
	if character.secondary_element != null:
		element2_display.color = character.secondary_element.color
	
	for attack in character.attacks:
		var item = AttackListItem.instantiate()
		var button = item.create(attack)
		button.hide()
		attacks_scroller.add_child(item)

	for key in character.stats.keys():
		var hbox = HBoxContainer.new()
		hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var name_label = Label.new()
		name_label.text = key
		hbox.add_child(name_label)
		
		var value_label = Label.new()
		value_label.text = str(character.stats[key])
		hbox.add_child(value_label)
		stats_vbox.add_child(hbox)

func clear():
	name_display.text = ""
	element1_display.color = Color.WHITE
	element2_display.color = Color("7f7f7f")
	
	for child in stats_vbox.get_children():
		stats_vbox.remove_child(child)
	for child in attacks_scroller.get_children():
		attacks_scroller.remove_child(child)
