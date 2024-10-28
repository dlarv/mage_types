extends Control
class_name Formatter

signal meta_clicked(obj)

func append_elemental_color(label: RichTextLabel, element: ElementalType) -> void:
	label.push_color(element.main_color)
	label.append_text(element.name)
	label.pop() # End color

func display(obj: Variant, limitInfo:=false) -> void:
	show()

func _format_attack_effects(effects: Array, effectsLabel: RichTextLabel) -> int:
	var power := 0
	for e in effects:
		var chance = int(e.chance * 100)
		var effect = e.attack_effect

		if effect is ElementalEffect:
			effectsLabel.push_meta(effect)
			append_elemental_color(effectsLabel, effect.element)
			effectsLabel.append_text("-%s" % effect.name)
			effectsLabel.pop() # Close meta tag
			effectsLabel.append_text(" %d%%." % chance)

		elif effect is StatusHeal:
			effectsLabel.append_text("%d%% chance to heal " % chance)
			effectsLabel.push_meta(effect.effect)
			effectsLabel.append_text("%s." % effect.effect.name)
			effectsLabel.pop() # Close meta tag

		elif effect is TransmutateAttackEffect:
			var label = "primary " if effect.element_id == 0 else "secondary"
			effectsLabel.append_text("%d%% chance to change the user's %s type to " % [chance, label])
			append_elemental_color(effectsLabel, effect.element)
			effectsLabel.append_text(".")

		elif effect is InstantHealthChange:
			var label = "heals" if effect.strength > 0 else "loses"
			effectsLabel.append_text("Instantly %s %d%% health." % [label, effect.strength * 100])

		elif effect is StatusEffect:
			effectsLabel.append_text("%d%% chance to cause " % chance)
			effectsLabel.push_meta(effect)
			effectsLabel.append_text("%s." % effect.name)
			effectsLabel.pop() # Close meta tag

		elif effect is StatChange:
			var label = "raise" if effect.strength > 0 else "lowers"
			effectsLabel.append_text("%d%% chance to %s %s." % [chance, label, effect.name])

		elif effect is InstantHealthChange:
			effectsLabel.append_text("Heals target by x%f their max hp." % effect.strength)

		elif effect is GenerateAffinity:
			effectsLabel.append_text("Gives %d affinity to the user. The element matches their current primary element." % effect.strength)

		elif effect is RandomPhobia:
			var a = effect.min_count
			var b = effect.max_count
			var number = str(a) if a == b else "%d-%d" % [a, b]
			effectsLabel.append_text("Gives the target %s random ")
			effectsLabel.push_meta(effect.Phobia)
			effectsLabel.append_text("phobias.")
			effectsLabel.pop() # pop meta
			if b > 1:
				effectsLabel.append_text(" Each phobia is of a unique element.")

		elif effect is Strike:
			if effect.type == Strike.StrikeType.STAB:
				effectsLabel.append_text("Deals x%.1f damage to " % effect.positive_factor)
				append_elemental_color(effectsLabel, effect.element)
				effectsLabel.append_text(" enemies. Otherwise, deals x%.1f damage." % effect.negative_factor)
			else:
				effectsLabel.append_text("Deals x%.1f damage if the user is " % effect.positive_factor)
				append_elemental_color(effectsLabel, effect.element)
				effectsLabel.append_text(". Otherwise, deals x%.1f damage." % effect.negative_factor)
		
		elif effect is DrainingDamage:
			power += effect.strength
			effectsLabel.append_text("Heals the user for x%.1f the damage dealt.")

		elif effect is Damage:
			if e.effect_target == Effect.EffectTarget.TARGET:
				power += effect.strength
			else:
				effectsLabel.append_text("%d%% chance to hurt the user.")


	return power

func _on_meta_clicked(meta: Variant) -> void:
	meta_clicked.emit(meta)
