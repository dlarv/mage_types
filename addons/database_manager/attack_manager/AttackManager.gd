@tool
extends PanelContainer

signal row_selected(row: Row)
signal file_selected(file_name: String)
signal removal_confirmed(val: bool)

const Row := preload("SpreadsheetRow.gd")
const ElementDropDown := preload("res://src/elements/gui/element_dropdown.tscn")
const ATTACK_PATH := "res://data/battle_system/battle_actions/attacks/"

var rows: Array[Row]
var file_dialog: EditorFileDialog

var _button_group := ButtonGroup.new()
var _selected_row: Row = null


func _enter_tree() -> void:
	$ConfirmationDialog.canceled.connect(func():
		removal_confirmed.emit(false)
	)
	$ConfirmationDialog.confirmed.connect(func():
		removal_confirmed.emit(true)
	)
	_on_load_button_pressed()
	if not file_dialog and Engine.is_editor_hint():
		file_dialog = EditorFileDialog.new()
		file_dialog.file_selected.connect(func(path: String) -> void:
			file_selected.emit(path)
		)
		file_dialog.get_cancel_button().pressed.connect(func() -> void:
			file_selected.emit("")
		)

		add_child(file_dialog)


func add_row(attack: Attack=null) -> void:
	var attackName := "Hit"
	if attack == null and file_dialog:
		attack = await _get_attack_from_fs()
		attackName = attack.name

	var select := CheckBox.new()
	select.button_group = _button_group

	var name := LineEdit.new()
	name.text = attackName
	var elements := ElementDropDown.instantiate()

	var attackRange := OptionButton.new()
	for key: String in _BattleAction.AttackRange.keys():
		attackRange.add_item(key)


	var targets := OptionButton.new()
	for key: String in _BattleAction.TargetType.keys():
		targets.add_item(key)

	var priority := SpinBox.new()
	priority.value = 0
	priority.step = 1

	var power := SpinBox.new()

	var accuracy := SpinBox.new()
	accuracy.value = 1.0
	accuracy.min_value = 0.05
	accuracy.max_value = 1.0
	accuracy.step = 0.05

	var scalingContainer := GridContainer.new()
	scalingContainer.columns = 2

	var noMatch := SpinBox.new()
	noMatch.tooltip_text = "No Match"
	noMatch.value = 100
	noMatch.step = 1.0
	noMatch.min_value = -500
	noMatch.max_value = 500
	scalingContainer.add_child(noMatch)

	var affinityMatch := SpinBox.new()
	affinityMatch.tooltip_text = "Affinity Match"
	affinityMatch.value = 100
	affinityMatch.step = 1.0
	affinityMatch.min_value = -500
	affinityMatch.max_value = 500
	scalingContainer.add_child(affinityMatch)

	var yesMatch := SpinBox.new()
	yesMatch.tooltip_text = "Match"
	yesMatch.value = 100
	yesMatch.step = 1.0
	yesMatch.min_value = -500
	yesMatch.max_value = 500
	scalingContainer.add_child(yesMatch)

	var doubleMatch := SpinBox.new()
	doubleMatch.tooltip_text = "Double Match"
	doubleMatch.value = -1
	doubleMatch.step = 1.0
	doubleMatch.min_value = -500
	doubleMatch.max_value = 500
	scalingContainer.add_child(doubleMatch)

	var description := TextEdit.new()
	description.placeholder_text = "Description"

	var row: Row = Row.new(select, name, elements, attackRange, targets, priority, power, accuracy, description, scalingContainer, attack)
	row.selected.connect(_on_row_selected)
	rows.append(row)

	%GridContainer.add_child(select)
	%GridContainer.add_child(name)
	%GridContainer.add_child(elements)
	%GridContainer.add_child(attackRange)
	%GridContainer.add_child(targets)
	%GridContainer.add_child(priority)
	%GridContainer.add_child(power)
	%GridContainer.add_child(accuracy)
	%GridContainer.add_child(scalingContainer)
	%GridContainer.add_child(description)

	if attack:
		name.text = attack.name
		if not attack.element.is_blank():
			elements.selected = ElementManager.elements.find(attack.element) + 1
		attackRange.selected = attack.attack_range
		targets.selected = attack.target
		priority.value = attack.priority
		power.value = attack.power
		accuracy.value = attack.accuracy
		description.text = attack.details
		noMatch.value = attack.scaling_factor.x
		affinityMatch.value = attack.scaling_factor.y
		yesMatch.value = attack.scaling_factor.z
		doubleMatch.value = attack.scaling_factor.w

		for child in scalingContainer.get_children():
			child.visible = power.value > 0


func remove_row() -> void:
	if not _selected_row: return
	$ConfirmationDialog.dialog_text = "Would you like to also remove the file at '%s'?" \
			% _selected_row.attack.resource_path
	$ConfirmationDialog.show()

	var val: bool = await removal_confirmed
	_selected_row.delete(val)
	rows.remove_at(rows.find(_selected_row))


func _on_row_selected(row: Row) -> void:
	_selected_row = row


func _on_load_button_pressed() -> void:
	for row in rows:
		row.delete()
	rows = []

	traverse(ATTACK_PATH)


func traverse(root: String) -> void:
	var dir := DirAccess.open(root)
	dir.list_dir_begin()

	var fileName := dir.get_next()
	while fileName != "":
		if fileName.ends_with(".tres"):
			add_row(ResourceLoader.load(root + "/" + fileName))
		elif dir.current_is_dir():
			traverse(root + "/" + fileName)

		fileName = dir.get_next()


func _get_attack_from_fs() -> Attack:
	file_dialog.popup_file_dialog()

	var path: String = await file_selected

	var attackName := path.split("/")[-1].split(".")[0]
	if attackName.is_empty():
		print("Attack creation cancelled.")
		return

	var attack := Attack.new()
	attack.name = attackName
	var err := ResourceSaver.save(attack, path + ".tres")
	if err != Error.OK:
		print("Error creating new attack %s at %s." % [attackName, path])
		error_string(err)
	else:
		print("New attack created at %s." % path)
	return attack
