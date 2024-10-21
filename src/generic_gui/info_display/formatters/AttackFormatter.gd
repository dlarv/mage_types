extends Formatter

@export var name_label: Label
@export var range_label: Label
@export var target_label: Label
@export var power_hbox: HBoxContainer
@export var power_label: Label
@export var cost_label: Label
@export var details: RichTextLabel
@export var effects_label: RichTextLabel
@export var element_icon: ElementIcon

func display(attack: Variant, limitInfo:=false) -> void:
	super.display(attack)
	
	# Basic info.
	name_label.text = attack.name
	range_label.text = Attack.AttackRange.keys()[attack.attack_range]
	target_label.text = Attack.TargetType.keys()[attack.target]
	cost_label.text = str(attack.cost)
	element_icon.element = attack.element

	# Only show power if attack has damage effects.
	power_label.text = ""
	power_hbox.hide()

	details.clear()
	if attack.details != null and len(attack.details) > 0:
		details.append_text(attack.details)
	
	effects_label.clear()
	var power = _format_attack_effects(attack.effects, effects_label)

	if power > 0:
		power_hbox.show()
		power_label.text = str(power)
