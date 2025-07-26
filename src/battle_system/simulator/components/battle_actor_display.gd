extends Control
@warning_ignore_start("untyped_declaration")

@export var AttackListItem: PackedScene

@export var name_display: Label
@export var element1_display: ColorRect
@export var element2_display: ColorRect
@export var stats_vbox: VBoxContainer
@export var attacks_scroller: VBoxContainer


func display(actor: BattleActor) -> void:
	clear()
	name_display.text = actor.name
	element1_display.color = actor.element1.main_color
	element2_display.color = actor.element2.main_color
	
	for attack in actor.attacks:
		var item := AttackListItem.instantiate()
		var button: Button = item.create(attack)
		button.hide()
		attacks_scroller.add_child(item)

	for key in actor.get_stats().keys():
		var hbox = HBoxContainer.new()
		hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var name_label = Label.new()
		name_label.text = key
		hbox.add_child(name_label)
		
		var value_label = Label.new()
		value_label.text = str(actor.get_stats()[key])
		hbox.add_child(value_label)
		stats_vbox.add_child(hbox)

func clear() -> void:
	name_display.text = ""
	element1_display.color = Color.WHITE
	element2_display.color = Color("7f7f7f")
	
	for child in stats_vbox.get_children():
		stats_vbox.remove_child(child)
	for child in attacks_scroller.get_children():
		attacks_scroller.remove_child(child)
