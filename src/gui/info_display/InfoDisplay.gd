extends RichTextLabel
class_name InfoDisplay

@export var button: Button 
@export var tab_container: TabContainer
@export var attack_formatter: Formatter
@export var item_formatter: Formatter
@export var actor_formatter: Formatter
@export var status_effect_formatter: Formatter

func _ready() -> void:
	tab_container.hide()
	button.pressed.connect(clear_message)

func display_message_blocking(msg: String) -> void:
	clear_message()
	append_text(msg)
	button.grab_focus()
	await button.pressed

func display_message_non_blocking(obj: Variant, limitInfo:=false) -> void:
	clear_message()
	button.hide()
	if obj is String:
		append_text(obj)
	else:
		format_msg(obj, limitInfo)

func format_msg(obj: Variant, limitInfo: bool) -> void:
	tab_container.show()

	if obj is Attack:
		attack_formatter.display(obj)

	elif obj is ItemSlot or obj is Item or obj is BattleItem:
		item_formatter.display(obj)

	elif obj is StatusEffect:
		status_effect_formatter.display(obj)

	elif obj is BattleActor:
		actor_formatter.display(obj, limitInfo)

func _on_link_clicked(obj: Variant) -> void:
	display_message_non_blocking(obj)

# [underline]<title>[/underline]
func append_title(title: String) -> void:
	push_underline()
	append_text(title)
	pop()

# [bold]<val>[/bold]: 
func append_header(val: String) -> void:
	push_bold()
	append_text(val)
	pop() # End bold 
	append_text(": ")

# [color]<element.Name>[/color]\n
func append_elemental_type(element: ElementalType, msg: String="Element") -> void:
	append_header(msg)
	append_elemental_color(element)
	newline()

func append_elemental_color(element: ElementalType):
	push_color(element.main_color)
	append_text(element.name)
	pop() # End color

func clear_message()-> void:
	tab_container.hide()
	button.show()
	text = ""
	clear()


func format_item(item: Item) -> void:
	pass

func format_battle_item(item: BattleItem) -> void:
	append_title(item.name)

	if item.element != ElementManager.Blank:
		append_elemental_type(item.element)

	if item.is_consumable:
		append_header("Quantity")
		append_text(str(item.quantity))
		newline()
	
	if len(item.details) > 0:
		append_header("Description")
		newline()
		append_text(item.details)

func format_status_effect(effect: StatusEffect) -> void:
	append_title(effect.name)
	append_header("Strength")
	append_text(str(effect.strength * 100.0) + "%")
	newline()
	append_header("Duration")
	append_text(str(effect.duration))
	newline()

func format_battle_actor(actor: BattleActor, limitInfo: bool) -> void:
	append_title(actor.name)
	append_elemental_type(actor.element1, "Primary Element")
	append_elemental_type(actor.element2, "Secondary Element")

	newline()
	append_header("Status Effects")
	newline()
	for effect in actor.list_status_effects():
		format_status_effect(effect)


	newline()
	if limitInfo: return
	append_header("Stats")
	newline()
	append_header("Hp")
	append_text("%d/%d" % [ actor.current_hp, actor.hp ])
	newline()

	append_header("Mana")
	append_text(str(actor.current_mana))
	newline()

	append_header("Melee Attack")
	append_text(str(actor.melee_attack))
	newline()

	append_header("Ranged Attack")
	append_text(str(actor.ranged_attack))
	newline()

	append_header("Melee Defense")
	append_text(str(actor.melee_attack))
	newline()

	append_header("Ranged Defense")
	append_text(str(actor.ranged_defense))
	newline()

	append_header("Speed")
	append_text(str(actor.speed))
	newline()

	newline()
	append_header("Attacks")
	newline()
	# for attack in actor.attacks:
	# 	format_attack(attack)
