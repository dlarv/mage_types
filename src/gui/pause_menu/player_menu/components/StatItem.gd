@tool
extends Control 

signal stat_modified(stat: String, amount: int)

@export_enum("MELEE_ATTACK", "RANGED_ATTACK", "MELEE_DEFENSE", "RANGED_DEFENSE", "SPEED", "EVASION", "HP")
var stat: String:
	set(value):
		stat = value
		_double_value = value == "HP" or value == "O_MANA" or value == "D_MANA"
		if _name_label == null: return
		_name_label.text = value.replace("_", " ").capitalize()

@export
var editable : bool:
	set(value):
		editable = value
		if _up_button == null or _down_button == null: return
		_up_button.visible = value
		_down_button.visible = value

@export
var debug_mode : bool:
	set(value):
		debug_mode = value
		editable = editable or value
		if _number_label == null: return
		_number_label.editable = value
		if _extra_number_label == null or not _extra_number_label.visible: return
		_extra_number_label.editable = value


@export
var value_1: float:
	set(value):
		value_1 = value
		if _number_label == null: return
		_number_label.text = str(value)
@export
var value_2: float:
	set(value):
		value_2 = value
		if _number_label == null: return
		_extra_number_label.text = str(value)
var _double_value := true:
	set(value):
		_double_value = value
		if _extra_number_label == null: return
		_extra_number_label.visible = value
		if _number_label_separator == null: return
		_number_label_separator.visible = value

@export var min_value: float = 0
@export var max_value: float = 1000
@export var step_value: float = 1

@export var _name_label: Label 
@export var _number_label: LineEdit 
@export var _extra_number_label: LineEdit
@export var _number_label_separator: Label
@export var _up_button: Button 
@export var _down_button: Button 

func _ready() -> void:
	if not Engine.is_editor_hint():
		debug_mode = ProjectSettings.get_setting("custom/general/debug_mode")

func _increment_stat(direction: int) -> void:
	value_1 += direction
	_number_label.text = str(value_1)
	stat_modified.emit(stat, value_1)

func set_value(actor: BattleActor) -> void:
	if stat == "HP":
		value_1 = actor.hp
		value_2 = actor.current_hp
	else:
		value_1 = actor.get_stat(StatManager.Stats.get(stat))
	if not stat_modified.is_connected(actor.set_stat):
		stat_modified.connect(actor.set_stat)
	

func _on_value_1_text_changed(newText: String) -> void:
	_number_label.release_focus()
	value_1 = newText.to_int()
	stat_modified.emit(stat, value_1)

func _on_value_2_text_changed(newText: String) -> void:
	value_2 = newText.to_int()
	_extra_number_label.release_focus()
	if stat == "O_MANA":
		stat_modified.emit("CURRENT_O_MANA", value_2)
	elif stat == "D_MANA":
		stat_modified.emit("CURRENT_D_MANA", value_2)
	elif stat == "HP":
		stat_modified.emit("CURRENT_HP", value_2)

func _on_number_2_text_changed(newText:String) -> void:
	if not newText.is_valid_int(): 
		_on_value_1_text_changed(newText)
		_number_label.release_focus()

func _on_number_1_text_changed(newText:String) -> void:
	if not newText.is_valid_int(): 
		_on_value_2_text_changed(newText)
		_extra_number_label.release_focus()
