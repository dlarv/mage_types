extends Control
class_name ThreeStateButton 

signal state_changed(state)

const UNSELECTED_STATE: int = 0
const FIRST_SELECTED_STATE: int = 1
const SECOND_SELECTED_STATE: int = 2
const SECOND_STATE_UNSELECTED: int = 3

@export var unselected_modulate_color: Color 
@export var selected_1_modulate_color: Color 
@export var selected_2_modulate_color: Color 
@export var locked_modulate_color: Color 

@export var button: Button 
@export var cost_label: RichTextLabel
var _element: ElementalType
var _total_cost: int
var text: String:
	get: return button.text
	set(value):  button.text = value

var button_group: ButtonGroup:
	get: return button.button_group
	set(value): button.button_group = value

# Prevents button from entering 3rd state.
var is_locked: bool = false: 
	get: return is_locked 
	set(value):
		is_locked = value
		state = UNSELECTED_STATE
		modulate = locked_modulate_color if value else unselected_modulate_color

var state: int = UNSELECTED_STATE


func _enter_tree():
	cost_label.hide()


func init_cost(element: ElementalType, cost: int) -> void:
	_element = element
	_total_cost = cost
	cost_label.show()


func update_cost(actor: BattleActor) -> void:
	if not cost_label.visible: return

	var affinity := actor.get_affinity_for(_element)
	var color = _element.main_color * min(affinity / _total_cost, 1)
	color.a = 1

	cost_label.clear()
	cost_label.push_color(color)
	cost_label.append_text("%d" % affinity)
	cost_label.pop() # Pop color

	cost_label.push_color(_element.main_color)
	cost_label.append_text("/%d" % _total_cost)
	cost_label.pop() # Pop color


func _on_pressed(toggled: bool) -> void:
	if not toggled:
		state = UNSELECTED_STATE
		modulate =  locked_modulate_color  if is_locked  else  unselected_modulate_color
	elif !is_locked && state == FIRST_SELECTED_STATE:
		state = SECOND_SELECTED_STATE
		modulate = selected_2_modulate_color
	elif state == SECOND_SELECTED_STATE:
		state = FIRST_SELECTED_STATE
		modulate = selected_1_modulate_color
		state_changed.emit(SECOND_STATE_UNSELECTED)
		return
	else:
		state = FIRST_SELECTED_STATE
		modulate = selected_1_modulate_color

	state_changed.emit(state)


func reset() -> void:
	modulate = unselected_modulate_color
	state = UNSELECTED_STATE
	button.set_pressed_no_signal(false)
