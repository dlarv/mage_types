@tool
extends RichTextEffect
class_name RichTextElement

var bbcode := 'el'

func _process_custom_fx(charFx: CharFXTransform) -> bool:
	if charFx.env.get("name"):
		charFx.env["color"] = _get_color(charFx.env["name"][0])
		charFx.env["name"] = null
	elif len(charFx.env) == 0:
		charFx.env["color"] = _get_color(char(
				TextServerManager.get_primary_interface().font_get_char_from_glyph_index(
						charFx.font, 1, charFx.glyph_index)).to_upper())
	charFx.color = charFx.env["color"]
	return true

func _get_color(key: String) -> Color:
	match key:
		"B": return ElementManager.Blue.main_color
		"P": return ElementManager.Purple.main_color
		"M": return ElementManager.Magenta.main_color
		"R": return ElementManager.Red.main_color
		"O": return ElementManager.Orange.main_color
		"Y": return ElementManager.Yellow.main_color
		"G": return ElementManager.Green.main_color
		"C": return ElementManager.Cyan.main_color
		"b",_: return ElementManager.Blank.main_color
