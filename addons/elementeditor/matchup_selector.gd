@tool
extends Control

signal item_selected(row: int, col: int, index: int, effect: int, mod: int)

var colors
var rect: ColorRect
var label: Label
var element_button: OptionButton
var effect_button: OptionButton
var damage_button: Button
var row: int
var col: int

var _element: int = -1
var _effect: int = 0
var _damage: int = 0
var _is_disabled: bool = false

func _ready():
	rect = find_child("ColorRect", true)
	label = find_child("Label", true)
	element_button = find_child("Element_Button", true)
	element_button.item_selected.connect(func(index): 
		_element = index - 1
		rect.color = colors[index].color
		item_selected.emit(row, col, index - 1, _effect, _damage)
		)
	
	effect_button = find_child("Effect_Button", true)
	effect_button.clear()
	effect_button.item_selected.connect(func(index):
		_effect = index
		var icon = ElementalEffect.get_icon(_effect)
		label.text = icon
		item_selected.emit(row, col, _element, index, _damage)
		)
	
	for effect in ElementalEffect.Effect.keys():
		effect_button.add_item(effect)
	
	damage_button = find_child("Damage_Button", true)
	damage_button.pressed.connect(_on_damage_button_pressed)
	
func set_coord(row: int, col: int):
	self.row = row
	self.col = col

func update(options):
	colors = [ElementalType.new("", Color.WHITE)]
	colors.append_array(options)
	element_button.clear()
	element_button.add_item("None")
	for opt in colors.slice(1):
		var texture = GradientTexture2D.new()
		var gradient = Gradient.new()
		gradient.set_color(0, opt.color)
		gradient.set_color(1, opt.color)
		texture.gradient = gradient
		element_button.add_icon_item(texture, opt.type_name)

func set_matchup(matchup: Matchup):
	if matchup == null:
		rect.color = Color.WHITE
		damage_button.text = "..\n\n"
		_damage = 0
		label.text = ""
		_effect = 0
		return
	if matchup.element == null:
		rect.color = Color.WHITE
	else:
		rect.color = matchup.element.color
		_element = MatchupManager.get_index_from_name(matchup.element.type_name)
		print(_element)
	_effect = matchup.effect
	var icon = ElementalEffect.get_icon(matchup.effect)
	label.text = icon
	
	_damage = matchup.modifier - 1
	if _damage == -2: _damage = 1
	_on_damage_button_pressed()
	

func set_disabled(val: bool):
	_is_disabled = val
	element_button.visible = not val
	effect_button.visible = not val
	damage_button.visible = not val
	
	if val:
		rect.color = Color.DARK_GRAY
	else:
		rect.color = Color.WHITE

func is_disabled():
	return _is_disabled

func _on_damage_button_pressed():
	match _damage:
		-1: 
			damage_button.text = "..\n\n"
			_damage = 0
		0:
			damage_button.text = "++\n\n"
			_damage = 1
		_:
			damage_button.text = "--\n\n"
			_damage = -1
	item_selected.emit(row, col, _element, _effect, _damage)
