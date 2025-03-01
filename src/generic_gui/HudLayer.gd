extends CanvasLayer

func show_overworld_spell(isPrimary: bool, spell: OverworldSpell) -> void:
	if isPrimary:
		%PrimarySpell_Rect.texture = spell.icon
	else:
		%SecondarySpell_Rect.texture = spell.icon
