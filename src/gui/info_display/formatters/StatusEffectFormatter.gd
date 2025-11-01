extends Formatter 

const Effects := StatusEffectManager.StatusEffects

@export var name_label: RichTextLabel
@export var details_label: RichTextLabel
@export var icon_parent: Control 

func display(effect: Variant, limitInfo:=false) -> void:
	super.display(effect)
	
	name_label.clear()
	name_label.append_text(effect.name)
	details_label.clear()

	if effect is PhobiaEffect:
		details_label.append_text("Deals %d%% damage every time this combatant becomes [el]%s[/el]." 
				% [int(effect.get_strength() * 100.0), effect.element])
	else:
		match effect.id:
			Effects.STASIS:
				details_label.append_text("Prevents this combatant from transmuting.")
			Effects.BLOCK:
				details_label.append_text("Blocks %d%% of damage from next attack." 
						% int(effect.get_strength() * 100.0))
			Effects.POISON:
				details_label.append_text("Deals %d%% damage over time." 
						% int(effect.get_strength() * 100.0))
			Effects.HEALING:
				details_label.append_text("Heals %d%% health over time." 
						% int(effect.get_strength() * 100.0))

	details_label.append_text(effect.description)
