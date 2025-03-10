extends CanvasLayer

signal vendor_menu_closed
signal catalyst_menu_closed(element: ElementalType)

@export var main_menu: Control
@export var player_menu: Menu
@export var inventory: Menu
@export var matchup_chart: Menu
@export var settings_menu: Menu
@export var vendor_menu: Menu
@export var save_menu: Menu
@export var catalyst_menu: Menu

var overworld: Node
var dialog_box: DialogueBox
var hud: CanvasLayer
var _menu_stack := []
var _block_input := false

func _ready() -> void:
	var root := get_tree().get_current_scene()
	overworld = root.get_node("%Overworld")
	dialog_box = root.get_node("%DialogueBox")
	hud = root.get_node("%HUD_Layer")
	hide()

func _unhandled_input(input: InputEvent) -> void:
	if _block_input: 
		if not inventory.visible: return
		if input.is_action_pressed("ui_cancel"):
			inventory.spell_scroll_selected.emit(null)
			inventory.equipment_selected.emit(null)
	elif visible and (input.is_action_pressed("close_menu") or input.is_action_pressed("pause_game")):
		if len(_menu_stack) > 0 and _menu_stack[-1] == vendor_menu:
			vendor_menu_closed.emit()
		pop_menu()
	elif len(_menu_stack) > 0 and input.is_action_pressed("next_menu_screen"):
		_menu_stack[-1].next_screen()
	elif len(_menu_stack) > 0 and input.is_action_pressed("prev_menu_screen"):
		_menu_stack[-1].prev_screen()
	else:
		_try_toggle_menu(input)

func _try_toggle_menu(input: InputEvent) -> void:
	if input.is_action_pressed("pause_game"):
		push_menu(main_menu)
	elif input.is_action_pressed("open_transmutation_menu"):
		push_menu(matchup_chart)
	elif input.is_action_pressed("open_inventory_menu"):
		push_menu(inventory)
	elif input.is_action_pressed("open_player_menu"):
		push_menu(player_menu)

func push_menu(menu: Control) -> void:
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	if len(_menu_stack) > 0 and menu == _menu_stack[-1]:
		pop_menu()
		return
	menu.show()
	_menu_stack.append(menu)
	show()

func pop_menu() -> void:
	var menu = _menu_stack.pop_back()
	if menu:
		menu.hide()
	if len(_menu_stack) == 0:
		overworld.process_mode = Node.PROCESS_MODE_INHERIT
		hide()
	else:
		_menu_stack[-1].show()

func show_dialog(msg: String) -> void:
	# Gets empty dialog box attached to MISC start node.
	dialog_box.data.nodes[dialog_box.data.nodes[dialog_box.data.starts["MISC"]]["link"]].dialogue = msg
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	dialog_box.start("MISC")
	await dialog_box.dialogue_ended
	overworld.process_mode = Node.PROCESS_MODE_INHERIT

func open_vendor_menu(vendor: VendorActor) -> void:
	_menu_stack.append(vendor_menu)
	vendor_menu.open_menu(vendor)
	vendor_menu.show()
	show()

func open_catalyst_menu(validElements: Dictionary) -> void:
	_menu_stack.append(catalyst_menu)
	catalyst_menu.open_menu(validElements)
	catalyst_menu.show()
	show()

func _on_catalyst_menu_closed(element:ElementalType) -> void:
	_menu_stack.pop_back()
	catalyst_menu.hide()
	catalyst_menu_closed.emit(element)
	hide()

func toggle_transmutation_menu() -> void:
	if len(_menu_stack) > 0 and _menu_stack[-1] == matchup_chart:
		_menu_stack.pop_back()
		matchup_chart.hide()
		hide()
	else:
		_menu_stack.append(matchup_chart)
		matchup_chart.show()
		show()

func _on_player_button_pressed() -> void:
	push_menu(player_menu)

func _on_inventory_button_pressed() -> void:
	push_menu(inventory)

func _on_transmutation_button_pressed() -> void:
	push_menu(matchup_chart)

func _on_open_settings_button_pressed() -> void:
	push_menu(settings_menu)

func _on_save_game_button_pressed() -> void:
	push_menu(save_menu)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_vendor_menu_menu_closed() -> void:
	_menu_stack.pop_back()
	vendor_menu_closed.emit()
	vendor_menu.hide()

func _on_player_menu_open_spell_menu(index: int, actor: BattleActor) -> void:
	_block_input = true
	inventory.show()
	var selection = await inventory.open_spell_scroll_menu()
	_menu_stack[-1].show()
	_block_input = false
	if selection != null:
		actor.learn_spell(selection, index)

func _on_player_menu_open_equipment_menu(actor: BattleActor) -> void:
	_block_input = true
	inventory.show()
	var selection = await inventory.open_equipment_menu()
	_menu_stack[-1].show()
	_block_input = false
	if selection != null:
		actor.equipment = selection
