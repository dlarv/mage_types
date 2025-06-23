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


func show_overworld_spell(isPrimary: bool, spell: OverworldSpell) -> void:
	if isPrimary:
		%PrimarySpell_Rect.texture = spell.icon
	else:
		%SecondarySpell_Rect.texture = spell.icon

