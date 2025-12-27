extends CanvasLayer

var start_time: float


func _ready() -> void:
	%VersionInfo.text = "v" + ProjectSettings.get_setting("application/config/version")
	start_time = Time.get_unix_time_from_system()


func _process(delta: float) -> void:
	%DebugInfo.text = "FPS: %d" % int(Engine.get_frames_per_second())
	var endTime := Time.get_unix_time_from_system()
	var elapsed := endTime - start_time
	%Stopwatch.text = Time.get_time_string_from_unix_time(int(elapsed))


func show_overworld_spell(spell: OverworldSpell) -> void:
	if spell.icon:
		%PrimarySpellRect.texture = spell.icon
		%PrimarySpellRect.show()
		%PrimarySpellRect2.hide()
	else:
		%PrimarySpellRect2.get_child(0).text = "%s" % spell.name.substr(0, 1)
		%PrimarySpellRect.hide()
		%PrimarySpellRect2.show()
