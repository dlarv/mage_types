extends ColorRect

const ALT_GRAY: Color = Color(.7, .7, .7)
const GRAY: Color = Color.LIGHT_GRAY

var row_header: ColorRect
var col_header: ColorRect
var is_hidden: bool
var hidden_color: Color

var _label_settings: LabelSettings = null:
	get():
		if _label_settings == null:
			_label_settings = LabelSettings.new()
			_label_settings.font_size = 32
			_label_settings.font_color = Color.BLACK
		return _label_settings

func _init(color:= Color.DARK_GRAY, isHidden:=false):
	is_hidden = isHidden
	if is_hidden:
		# Cell has nothing to hide:
		if color == ALT_GRAY:
			is_hidden = false
			self.color = ALT_GRAY
		else:
			hidden_color = color
			self.color = GRAY
	else:
		self.color = color


	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


	var text := Label.new()
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	text.label_settings = _label_settings
	text.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)

	add_child(text)

func focus(val: bool) -> void:
	reveal(false)
	if val:
		color.a = 1
		if col_header != null:
			col_header.color.a = 1
			row_header.color.a = 1
	else:
		color.a = .2
		if col_header != null:
			col_header.color.a = .2
			row_header.color.a = .2

func set_headers(col: ColorRect, row: ColorRect) -> void:
	col_header = col
	row_header = row


func reveal(val: bool) -> void:
	if not is_hidden: return
	if val:
		color = hidden_color
	else:
		color = GRAY
