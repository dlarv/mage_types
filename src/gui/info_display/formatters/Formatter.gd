extends Control
class_name Formatter

signal meta_clicked(obj: Variant)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const AttackFormatter := preload("res://src/gui/info_display/formatters/AttackFormatter.gd")

func _enter_tree() -> void:
	var effect1 := RichTextElement.new()
	for child in find_children("", "RichTextLabel", true):
		child.install_effect(effect1)


func append_elemental_color(label: RichTextLabel, element: ElementalType) -> void:
	label.push_color(element.main_color)
	label.append_text(element.name)
	label.pop() # End color


func display(obj: Variant, limitInfo:=false) -> void:
	show()


func _format_attack_effects(effects: Array[Variant], effectsLabel: RichTextLabel) -> int:
	var power := 0
	for e: _BaseEffectSlot in effects:
		if e is EffectSlot:
			power += _format_attack_effect(e, effectsLabel)
		elif e is ConditionalEffect:
			if e.condition is ElementalCondition:
				effectsLabel.append_text("Elemental Condition")
				power += _format_elemental_condition(e, effectsLabel)
			pass

	return power


func _format_attack_effect(e: EffectSlot, effectsLabel: RichTextLabel) -> int:
	var chance := int(e.chance * 100)
	var effect := e.attack_effect
	var power := 0.0

	if effect is PhobiaEffect:
		effectsLabel.push_meta(effect)
		append_elemental_color(effectsLabel, effect.element)
		effectsLabel.append_text("-Phobia")
		effectsLabel.pop() # Close meta tag
		effectsLabel.append_text(" %d%%." % chance)

	elif effect is StatusHeal:
		effectsLabel.append_text("%d%% chance to heal " % chance)
		effectsLabel.push_meta(effect.effect)
		effectsLabel.append_text("%s." % effect.effect.name)
		effectsLabel.pop() # Close meta tag

	elif effect is TransmutateAttackEffect:
		var label := "primary " if effect.element_id == 0 else "secondary"
		effectsLabel.append_text("%d%% chance to change the user's %s type to " % [chance, label])
		append_elemental_color(effectsLabel, effect.element)
		effectsLabel.append_text(".")

	elif effect is InstantHealthChange:
		var label := "heals" if effect.get_strength() > 0 else "loses"
		effectsLabel.append_text("Instantly %s %d%% health." % [label, effect.get_strength() * 100])

	elif effect is StatusEffect:
		effectsLabel.append_text("%d%% chance to cause " % chance)
		effectsLabel.push_meta(effect)
		effectsLabel.append_text("%s." % effect.name)
		effectsLabel.pop() # Close meta tag

	elif effect is StatChange:
		var label := "raise" if effect.get_strength() > 0 else "lowers"
		effectsLabel.append_text("%d%% chance to %s %s." % [chance, label, effect.name])

	elif effect is InstantHealthChange:
		effectsLabel.append_text("Heals target by x%f their max hp." % effect.strength)

	elif effect is RandomPhobia:
		var a: int = effect.min_count
		var b: int = effect.max_count
		var number := str(a) if a == b else "%d-%d" % [a, b]
		effectsLabel.append_text("Gives the target %d random " % number)
		effectsLabel.push_meta(PhobiaEffect.new())
		effectsLabel.append_text("phobias.")
		effectsLabel.pop() # pop meta
		if b > 1:
			effectsLabel.append_text(" Each phobia is of a unique element.")

	#elif effect is Strike:
		#if effect.type == Strike.StrikeType.STAB:
			#effectsLabel.append_text("Deals x%.1f damage to " % effect.positive_factor)
			#append_elemental_color(effectsLabel, effect.element)
			#effectsLabel.append_text(" enemies. Otherwise, deals x%.1f damage." % effect.negative_factor)
		#else:
			#effectsLabel.append_text("Deals x%.1f damage if the user is " % effect.positive_factor)
			#append_elemental_color(effectsLabel, effect.element)
			#effectsLabel.append_text(". Otherwise, deals x%.1f damage." % effect.negative_factor)
	#
	elif effect is Damage:
		if e.effect_target == EffectSlot.EffectTarget.TARGET:
			power += effect.get_strength()
		else:
			effectsLabel.append_text("Does recoil damage on user.")
	return int(power)


func _format_elemental_condition(e: ConditionalEffect, effectsLabel: RichTextLabel) -> int:
	var success_power := 0
	var fail_power := 0

	var elements: Array = e.condition.elements.map(func(x: ElementalType) -> String: 
		return x.get_bb_code_name()
	)
	var op: String
	var op2 := ""
	match e.condition.operator:
		"any":
			op = "OR"
		"all":
			op = "AND"
		"ne":
			op = "OR"
			op2 = "NOT "

	var elementsString: String
	if len(elements) > 0:
		elements[-1] = "%s %s" % [op, elements[-1]]
		elementsString = ", ".join(elements)
	else:
		push_warning("ElementalCondition has empty elements array.")
		elementsString = "null"
	
	effectsLabel.newline()
	effectsLabel.append_text("Condition(s):")
	effectsLabel.newline()
	if e.condition.apply_to == "user" or e.condition.apply_to == "both":
		effectsLabel.append_text("- User is %s%s" % [op2, elementsString])
		effectsLabel.newline()
	if e.condition.apply_to == "target" or e.condition.apply_to == "both":
		effectsLabel.append_text("- Target is %s%s" % [op2, elementsString])
		effectsLabel.newline()

	effectsLabel.append_text("If all conditions are true:")
	effectsLabel.newline()
	success_power += _format_attack_effect(e.success_effect, effectsLabel)
	if e.failed_effect != null:
		effectsLabel.newline()
		effectsLabel.append_text("Otherwise:")
		effectsLabel.newline()
		fail_power += _format_attack_effect(e.failed_effect, effectsLabel)

	return int((success_power + fail_power) / 2.0)


func _on_meta_clicked(meta: Variant) -> void:
	if meta is String:
		var statuses := StatusEffectManager.StatusEffects.keys()
		if meta.to_upper() in statuses:
			meta_clicked.emit(StatusEffectManager.get_generic_status_effect(
				StatusEffectManager.StatusEffects[meta.to_upper()]))
	else:
		meta_clicked.emit(meta)
