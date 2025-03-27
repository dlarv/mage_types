extends CanvasLayer


func _process(delta: float) -> void:
	%DebugInfo.text = "FPS: %d" % int(Engine.get_frames_per_second())


func show_overworld_spell(isPrimary: bool, spell: OverworldSpell) -> void:
	if isPrimary:
		%PrimarySpell_Rect.texture = spell.icon
	else:
		%SecondarySpell_Rect.texture = spell.icon

