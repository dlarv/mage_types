extends Formatter

@export var id_label: Label
@export var name_label: Label
@export var is_consumable_hbox: HBoxContainer
@export var is_consumable_box: CheckBox 
@export var req_vbox: VBoxContainer
@export var req_label: RichTextLabel
@export var details_label: RichTextLabel
@export var attack_formatter: Formatter

func display(obj: Variant, limitInfo:=false) -> void:
	super.display(obj)
	req_label.clear()
	details_label.clear()
	attack_formatter.hide()

	var quantity := 0
	var item: Variant
	if obj is ItemSlot:
		item = obj.item
		quantity = obj.quantity
	else:
		item = obj

	if item is KeyItem:
		display_key_item(item)
	elif item is SpellScroll:
		display_spell_scroll(item)
	elif item is RegularItem:
		display_regular_item(item, quantity)
	elif item is Equipment:
		display_equipment(item)
	else:
		display_battle_item(item)

func display_regular_item(item: Item, quantity: int) -> void:
	id_label.show()
	id_label.text = "#%d" % item.id
	name_label.text = "%s (x%d)" % [ item.name, quantity ]

	is_consumable_hbox.show()
	is_consumable_box.button_pressed = item.is_consumable

	details_label.append_text(item.details)

	if item.battle_item != null:
		details_label.newline()
		_format_attack_effects(item.battle_item.effects, details_label)

	_format_requirement(item.requirements)

func display_spell_scroll(item: SpellScroll) -> void:
	id_label.show()
	is_consumable_hbox.hide()

	id_label.text = "#%d" % item.id
	name_label.text = item.name

	details_label.append_text(item.spell.details)

	_format_requirement(item.requirements)

	attack_formatter.display(item.spell)

func display_equipment(item: Equipment) -> void:
	id_label.show()
	details_label.show()
	is_consumable_hbox.hide()

	id_label.text = "#%d" % item.id
	name_label.text = item.name

	details_label.append_text(item.details)
	_format_requirement(item.requirements)

func display_battle_item(item: BattleItem) -> void:
	id_label.hide()
	name_label.text = "%s (x%d)" % [ item.name, item.quantity ]
	is_consumable_hbox.show()
	is_consumable_box.button_pressed = item.is_consumable

	details_label.append_text(item.details)
	details_label.newline()
	_format_attack_effects(item.effects, details_label)

	_format_requirement(item.requirements)

func display_key_item(item: KeyItem) -> void:
	id_label.hide()
	req_vbox.hide()
	is_consumable_hbox.hide()

	name_label.text = item.name
	details_label.append_text(item.details)

func _format_requirement(reqs: Array[ItemRequirement]) -> void:
	req_vbox.visible = len(reqs) > 0
	if len(reqs) == 0: return

	for req in reqs:
		if req is BiasRequirement:
			req_label.append_text("User must be ")
			append_elemental_color(req_label, req.element)
			req_label.append_text("-aligned to use this item.")
		
		elif req is ElementRequirement:
			req_label.append_text("User's primary/secondary type must be ")
			append_elemental_color(req_label, req.element)
			req_label.append_text(" to use this item.")

		elif req is NameRequirement:
			req_label.append_text("This item can only be used by %s." % req.required_name)
		
		elif req is StatRequirement:
			req_label.append_text("The user's %s stat must be %d or higher." % [req.stat, req.threshold])

		elif req is StatusEffectRequirement:
			req_label.append_text("User must have the ")
			req_label.push_meta(req.effect)
			req_label.append_text("%s" % req.effect.name)
			req_label.pop()
			req_label.append_text(" status effect to use this item.")

		elif req is AttackRequirement:
			if req.incompatible:
				req_label.append_text("User must not know any of the following spells:")	
			else:
				req_label.append_text("User must know all of the following spells:")

			for attack in req.attacks:
				req_label.push_list(1, RichTextLabel.ListType.LIST_DOTS, true)
				req_label.push_meta(attack)
				req_label.append_text(attack.name)
				req_label.pop() # Pop meta
				req_label.pop() # Pop list


		req_label.newline()
