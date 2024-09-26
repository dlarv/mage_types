extends Control
class_name Formatter

signal meta_clicked(obj)

func append_elemental_color(label: RichTextLabel, element: ElementalType):
	label.push_color(element.main_color)
	label.append_text(element.name)
	label.pop() # End color

func display(obj):
	show()

func _format_attack_effects(effects: Array, effectsLabel: RichTextLabel):
	var power = 0
	for e in effects:
		var chance = int(e.chance * 100)
		var effect = e.attack_effect

		if effect is Damage:
			if e.effect_target == Effect.EffectTarget.TARGET:
				power += effect.strength
			else:
				effectsLabel.append_text("%d%% chance to hurt the user.")

		elif effect is ElementalEffect:
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

	return power

func _on_meta_clicked(meta):
	meta_clicked.emit(meta)
