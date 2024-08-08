extends CanvasLayer
class_name PlayerControl

signal attack_selected(attack: Attack, id: int)
signal actor_selected(actor: BattleActor.Fighter, id: int)
signal messages_cleared

const ID: int = 0

@export var control_panel: PanelContainer
@export var home_controls: MarginContainer
@export var attack_parent: MarginContainer
@export var team_parent: MarginContainer
@export var attack_controls: VBoxContainer
@export var team_controls: VBoxContainer
@export var message_box: Label
@export var message_button: Button
@export var matchup_editor: Control
@export var screen: Panel
var _messages = []

var _is_expanded = false

func _unhandled_key_input(event: InputEvent):
	if event.keycode == KEY_SPACE and event.is_pressed():
		matchup_editor.visible = not matchup_editor.visible

func populate_team_controls(team: Array):
	for child in team_controls.get_children():
		team_controls.remove_child(child)

	for actor in team:
		var button = Button.new()
		button.text = actor.actor_name
		button.icon = actor.sprite.texture
		team_controls.add_child(button)
		button.pressed.connect(func(): actor_selected.emit(actor, ID))

func populate_attack_controls(actor: BattleActor.Fighter):
	for child in attack_controls.get_children():
		attack_controls.remove_child(child)
	
	for attack in actor.attacks:
		var button = Button.new()
		button.text = attack.attack_name
		attack_controls.add_child(button)
		button.pressed.connect(func(): attack_selected.emit(attack, ID))

func switch(index: int):
	home_controls.visible = index == 0
	attack_parent.visible = index == 1
	team_parent.visible = index == 2
	_is_expanded = index == 2
	
	if _is_expanded:
		control_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		control_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
		control_panel.size_flags_vertical = Control.SIZE_SHRINK_END

func set_enabled(val: bool):
	screen.visible = not val

func show_message(msg: String):
	message_box.text = msg
	await message_button.pressed
	message_box.text = ""

func append_message(msg: String):
	if message_box.text.is_empty():
		message_box.text = msg
	else: 
		_messages.append(msg)

func _on_message_cleared():
	if len(_messages) == 0:
		messages_cleared.emit()
		message_box.text = ""
		return

	var msg = _messages.pop_front()
	message_box.text = msg
