extends Formatter

func display(attack: Variant, limitInfo:=false) -> void:
	super.display(attack)
	
	# Basic info.
	%Name.text = attack.name
	%Range.text = Attack.AttackRange.keys()[attack.attack_range]
	%Target.text = Attack.TargetType.keys()[attack.target]
	%Priority.text = str(attack.priority)
	%Element.element = attack.element

	# Only show power if attack has damage effects.
	%Power.text = ""
	# power.hide()
	%Accuracy.text = "%d%%" % [ int(attack.accuracy * 100.0) ]

	%Details.clear()
	%Effects.clear()
	if attack.details != null and len(attack.details) > 0:
		%Details.append_text(attack.details)
	else:
		_format_attack_effects(attack.effects, %Effects)
	
	var power: float = attack.power
	if power > 0:
		%Power.text = str(int(power))
	else:
		%Power.text = "n/a"
	
	if attack.scaling_factor.x != -1:
		_format_scaling_factor(
				%ScalingFactorHBox/XLabel,
				null,
				attack.scaling_factor.x,
				"If the user is neither [el]%s[/el] nor has %s affinity, this attack will be at %d%% power." \
					% [attack.element, attack.element.get_affinity_bb_code_name(false), attack.scaling_factor.x]
			)
	else:
		%ScalingFactorHBox/XLabel.hide()

	if attack.scaling_factor.y != -1:
		_format_scaling_factor(
				%ScalingFactorHBox/YLabel,
				%ScalingFactorHBox/Label1,
				attack.scaling_factor.y,
				"If the user has %s affinity, this attack will be at %d%% power." \
					% [attack.element.get_affinity_bb_code_name(false), attack.scaling_factor.y]
			)
	else:
		%ScalingFactorHBox/YLabel.hide()
		%ScalingFactorHBox/Label1.hide()

	if attack.scaling_factor.z != -1:
		_format_scaling_factor(
				%ScalingFactorHBox/ZLabel,
				%ScalingFactorHBox/Label2,
				attack.scaling_factor.z,
				"If the user is [el]%s[/el], this attack will be at %d%% power." \
					% [attack.element, attack.scaling_factor.y]
			)
	else:
		%ScalingFactorHBox/ZLabel.hide()
		%ScalingFactorHBox/Label2.hide()

	if attack.scaling_factor.w != -1:
		_format_scaling_factor(
				%ScalingFactorHBox/WLabel,
				%ScalingFactorHBox/Label3,
				attack.scaling_factor.w,
				"If both of the user's types are [el]%s[/el], this attack will be at %d%% power." \
					% [attack.element, attack.scaling_factor.y]
			)
	else:
		%ScalingFactorHBox/WLabel.hide()
		%ScalingFactorHBox/Label3.hide()


func _format_scaling_factor(textLabel: Label, divider: Label, value: int, msg: String) -> void:
	if divider:
		divider.show()
	textLabel.show()
	textLabel.text = str(value)
	textLabel.tooltip_text = msg
