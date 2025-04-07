extends PanelContainer

signal row_selected(row: Row)

const Row := preload("components/SpreadsheetRow.gd")
const ElementDropDown := preload("res://src/elements/gui/element_dropdown.tscn")
const ATTACK_PATH := "res://data/battle_system/battle_actions/attacks/"

var rows: Array[Row]

var _button_group := ButtonGroup.new()
var _selected_row: Row = null

func _enter_tree() -> void:
	_on_load_button_pressed()


func add_row(attack: Attack=null) -> void:
	var select := CheckBox.new()
	select.button_group = _button_group
	var name := LineEdit.new()
	name.text = "Hit"
	var elements := ElementDropDown.instantiate()

	var attackRange := OptionButton.new()
	attackRange.add_item("Melee") 
	attackRange.add_item("Ranged") 
	attackRange.add_item("Status")

	var targets := OptionButton.new()
	targets.add_item("Self")
	targets.add_item("Ally")
	targets.add_item("Allies")
	targets.add_item("Enemy")
	targets.add_item("Enemies")
	targets.add_item("All")
	targets.add_item("Random")

	var priority := SpinBox.new()
	priority.value = 0
	priority.step = 1

	var power := SpinBox.new()

	var accuracy := SpinBox.new()
	accuracy.value = 1.0
	accuracy.min_value = 0.05
	accuracy.max_value = 1.0
	accuracy.step = 0.05

	var description := TextEdit.new()
	description.placeholder_text = "Description"

	var row: Row = Row.new(select, name, elements, attackRange, targets, priority, power, accuracy, description, attack)
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


func remove_row() -> void:
	if not _selected_row: return
	_selected_row.delete()
	rows.remove_at(rows.find(_selected_row))


func edit_row() -> void:
	if not _selected_row: return
	row_selected.emit(_selected_row)



func _on_row_selected(row: Row) -> void:
	_selected_row = row


func _on_load_button_pressed() -> void:
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


