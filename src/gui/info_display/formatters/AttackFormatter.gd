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
	
	var power: float = attack.power
	if power > 0:
		power_hbox.show()
		power_label.text = str(power)
	
	if attack.scaling_factor.x != -1:
		_format_scaling_factor(
				%VBoxContainer/ScalingFactorHBox/XLabel,
				null,
				attack.scaling_factor.x,
				"If the user is neither [el]%s[/el] nor has %s affinity, this attack will be at %d%% power." \
					% [attack.element, attack.element.get_affinity_bb_code_name(false), attack.scaling_factor.x]
			)
	else:
		%VBoxContainer/ScalingFactorHBox/XLabel.hide()

	if attack.scaling_factor.y != -1:
		_format_scaling_factor(
				%VBoxContainer/ScalingFactorHBox/YLabel,
				%VBoxContainer/ScalingFactorHBox/Label1,
				attack.scaling_factor.y,
				"If the user has %s affinity, this attack will be at %d%% power." \
					% [attack.element.get_affinity_bb_code_name(false), attack.scaling_factor.y]
			)
	else:
		%VBoxContainer/ScalingFactorHBox/YLabel.hide()
		%VBoxContainer/ScalingFactorHBox/Label1.hide()

	if attack.scaling_factor.z != -1:
		_format_scaling_factor(
				%VBoxContainer/ScalingFactorHBox/ZLabel,
				%VBoxContainer/ScalingFactorHBox/Label2,
				attack.scaling_factor.z,
				"If the user is [el]%s[/el], this attack will be at %d%% power." \
					% [attack.element, attack.scaling_factor.y]
			)
	else:
		%VBoxContainer/ScalingFactorHBox/ZLabel.hide()
		%VBoxContainer/ScalingFactorHBox/Label2.hide()

	if attack.scaling_factor.w != -1:
		_format_scaling_factor(
				%VBoxContainer/ScalingFactorHBox/WLabel,
				%VBoxContainer/ScalingFactorHBox/Label3,
				attack.scaling_factor.w,
				"If both of the user's types are [el]%s[/el], this attack will be at %d%% power." \
					% [attack.element, attack.scaling_factor.y]
			)
	else:
		%VBoxContainer/ScalingFactorHBox/WLabel.hide()
		%VBoxContainer/ScalingFactorHBox/Label3.hide()


func _format_scaling_factor(textLabel: Label, divider: Label, value: int, msg: String) -> void:
	if divider:
		divider.show()
	textLabel.show()
	textLabel.text = str(value)
	textLabel.tooltip_text = msg

