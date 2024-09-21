@tool
extends Control 
class_name StatItem 

signal StatModified(name, amount)

@export
var Text : String:
	get:
		if nameLabel == null: return ""
		return nameLabel.text
	
	set(value):
		if nameLabel == null: return
		nameLabel.text = value

@export
var Editable : bool:
	get:
		return _editable
	
	set(value):
		_editable = value
		if upButton == null or downButton == null: return
		upButton.visible = value
		downButton.visible = value

var _editable = true
@export
var DebugMode : bool:
	get:
		return _debugMode
	set(value):
		_debugMode = value
		if numberLabel == null: return
		numberLabel.editable = value
		Editable = Editable or value
var _debugMode = true

@export
var Value : int:
	get: 
		return _value
	set(value):
		_value = value
		if numberLabel == null: return
		numberLabel.text = str(value)

var _value = 0


@export
var MinValue : int = 0
@export
var MaxValue : int = 1000

@export
var nameLabel: Label 
@export
var numberLabel: LineEdit 
@export
var upButton: Button 
@export
var downButton: Button 

func _ready() -> void:
	pass
	# if(Settings.Singleton != null) {
	# 	Settings.Singleton.Connect(
	# 		Settings.SignalName.DebugModeToggled, 
	# 		Callable.From((bool val) => {
	# 			DebugMode = val

func IncrementStat(direction: int) -> void:
	_value += direction
	numberLabel.text = "" + _value
	StatModified.emit(Text.to_lower().strip_edges(), Value)

func ChangeValue(value) -> void:
	if value is BattleActor:
		Value = value.GetStat(Text.to_lower().strip_edges())
	else:
		Value = value

func OnTextChanged(newText: String) -> void:
	# From what I can tell, this should remove non-numeric symbols from string,
	# but it doesn't seem to do that.
	Value = newText.to_int()
	StatModified.emit(Text.to_lower().strip_edges(), Value)
