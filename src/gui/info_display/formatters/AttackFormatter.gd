extends Formatter

@export var name_label: Label
@export var range_label: Label
@export var target_label: Label
@export var power_hbox: HBoxContainer
@export var power_label: Label
@export var accuracy_label: Label
@export var priority_label: Label
@export var details: RichTextLabel
@export var effects_label: RichTextLabel
@export var element_icon: ElementIcon

func display(attack: Variant, limitInfo:=false) -> void:
	super.display(attack)
	
	# Basic info.
	name_label.text = attack.name
	accuracy_label.text = "%d%%" % [ int(attack.accuracy * 100.0) ]
	range_label.text = Attack.AttackRange.keys()[attack.attack_range]
	target_label.text = Attack.TargetType.keys()[attack.target]
	priority_label.text = str(attack.priority)
	element_icon.element = attack.element

	# Only show power if attack has damage effects.
	power_label.text = ""
	power_hbox.hide()

	details.clear()
	effects_label.clear()
	if attack.details != null and len(attack.details) > 0:
		details.append_text(attack.details)
	else:
		_format_attack_effects(attack.effects, effects_label)
	
	var power = attack.power

	if power > 0:
		power_hbox.show()
		power_label.text = str(power)
