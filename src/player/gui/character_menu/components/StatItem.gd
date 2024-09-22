@tool
extends Control 
class_name StatItem 

signal stat_modified(name, amount)

@export
var text : String:
	get:
		if nameLabel == null: return ""
		return nameLabel.text
	
	set(value):
		if nameLabel == null: return
		nameLabel.text = value

@export
var editable : bool:
	get:
		return editable
	set(value):
		editable = value
		if upButton == null or downButton == null: return
		upButton.visible = value
		downButton.visible = value

@export
var debug_mode : bool:
	get:
		return debug_mode
	set(value):
		debug_mode = value
		if numberLabel == null: return
		numberLabel.editable = value
		editable = editable or value

@export
var value : int:
	get: 
		return value
	set(v):
		value = v
		if numberLabel == null: return
		numberLabel.text = str(value)

@export
var min_value : int = 0
@export
var max_value : int = 1000

@export
var nameLabel: Label 
@export
var numberLabel: LineEdit 
@export
var upButton: Button 
@export
var downButton: Button 

func _ready() -> void:
	if Engine.is_editor_hint():
		Settings.debug_mode_toggled.connect(func(val): debug_mode = val)

func increment_stat(direction: int) -> void:
	value += direction
	numberLabel.text = str(value)
	stat_modified.emit(text.to_lower().strip_edges(), value)

func change_value(value) -> void:
	if value is BattleActor:
		self.value = value.get_stat(text.to_lower().strip_edges())
	else:
		self.value = value

func on_text_changed(newText: String) -> void:
	# From what I can tell, this should remove non-numeric symbols from string,
	# but it doesn't seem to do that.
	value = newText.to_int()
	stat_modified.emit(text.to_lower().strip_edges(), value)
