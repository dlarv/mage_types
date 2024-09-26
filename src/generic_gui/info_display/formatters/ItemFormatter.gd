extends Formatter

@export
var id_label: Label
@export
var name_label: Label
@export
var is_consumable_vbox: VBoxContainer
@export
var is_consumable_box: CheckBox 
@export
var req_vbox: VBoxContainer
@export
var req_label: RichTextLabel
@export
var details_label: RichTextLabel

func display(obj):
	super.display(obj)
	req_label.clear()
	details_label.clear()

	if obj is KeyItem:
		display_key_item(obj)
	elif obj is SpellScroll:
		display_spell_scroll(obj)
	elif obj is RegularItem:
		display_regular_item(obj)
	elif obj is Equipment:
		display_equipment(obj)
	else:
		display_battle_item(obj)

func display_regular_item(item: Item):
	id_label.show()
	id_label.text = "#%d" % item.id
	name_label.text = "%s (x%d)" % [ item.name, item.quantity ]

	is_consumable_vbox.show()
	is_consumable_box.button_pressed = item.is_consumable

	details_label.append_text(item.details)

	if item.battle_item != null:
		details_label.newline()
		_format_attack_effects(item.battle_item.effects, details_label)

	_format_requirement(item.requirement)

func display_spell_scroll(item: SpellScroll):
	id_label.show()
	is_consumable_vbox.hide()

	id_label.text = "#%d" % item.id
	name_label.text = item.name

	details_label.append_text(item.spell.details)

	_format_requirement(item.requirement)

func display_equipment(item: Equipment):
	id_label.show()
	is_consumable_vbox.hide()

	id_label.text = "#%d" % item.id
	name_label.text = item.name

	details_label.append_text(item.details)
	_format_requirement(item.requirement)

func display_battle_item(item: BattleItem):
	id_label.hide()
	name_label.text = "%s (x%d)" % [ item.name, item.quantity ]
	is_consumable_vbox.show()
	is_consumable_box.button_pressed = item.is_consumable

	details_label.append_text(item.details)
	details_label.newline()
	_format_attack_effects(item.effects, details_label)

	for req in item.requirements:
		_format_requirement(req)
		req_label.newline()

func display_key_item(item: KeyItem):
	id_label.hide()
	req_vbox.hide()
	is_consumable_vbox.hide()

	name_label.text = item.name
	details_label.append_text(item.details)

func _format_requirement(req: ItemRequirement):
	req_vbox.visible = req != null
	if req == null: return

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

