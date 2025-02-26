extends CanvasLayer

signal vendor_menu_closed

@export var main_menu: Control
@export var player_menu: Menu
@export var inventory: Menu
@export var matchup_chart: Menu
@export var settings_menu: Menu
@export var vendor_menu: Menu

var overworld: Node
var _active_menu: Menu = null
var _block_input := false

func _ready() -> void:
	overworld = get_tree().get_root().get_children()[-1].get_node("%Overworld")
	hide()

func _unhandled_input(input: InputEvent) -> void:
	if _block_input: 
		if not inventory.visible: return
		if input.is_action_pressed("ui_cancel"):
			inventory.spell_scroll_selected.emit(null)
			inventory.equipment_selected.emit(null)
		return
	if not visible: 
		_try_toggle_menu(input)
		return
	if input.is_action_pressed("close_menu") or input.is_action_pressed("pause_game"):
		if _active_menu == vendor_menu:
			vendor_menu_closed.emit()
		_active_menu = null
		overworld.process_mode = Node.PROCESS_MODE_INHERIT
		hide()
	elif input.is_action_pressed("next_menu_screen") and _active_menu != null:
		_active_menu.next_screen()
	elif input.is_action_pressed("prev_menu_screen") and _active_menu != null:
		_active_menu.prev_screen()

func _try_toggle_menu(input: InputEvent) -> void:
	if input.is_action_pressed("pause_game"):
		overworld.process_mode = Node.PROCESS_MODE_DISABLED
		main_menu.show()
		show()
	elif input.is_action_pressed("open_transmutation_menu"):
		overworld.process_mode = Node.PROCESS_MODE_DISABLED
		matchup_chart.show()
		_active_menu = matchup_chart
		show()



func open_vendor_menu(vendor: VendorActor) -> void:
	_active_menu = vendor_menu
	vendor_menu.open_menu(vendor)
	vendor_menu.show()

func toggle_transmutation_menu() -> void:
	if _active_menu == matchup_chart:
		_active_menu = null
		matchup_chart.hide()
		hide()
	else:
		_active_menu = matchup_chart
		matchup_chart.show()
		show()

func _on_player_button_pressed() -> void:
	_active_menu = player_menu
	player_menu.show()

func _on_inventory_button_pressed() -> void:
	_active_menu = inventory
	inventory.show()

func _on_transmutation_button_pressed() -> void:
	_active_menu = matchup_chart
	matchup_chart.show()

func _on_open_settings_button_pressed() -> void:
	_active_menu = settings_menu
	settings_menu.show()

func _on_save_game_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_vendor_menu_menu_closed() -> void:
	vendor_menu_closed.emit()
	vendor_menu.hide()

func _on_player_menu_open_spell_menu(index: int, actor: BattleActor) -> void:
	_block_input = true
	inventory.show()
	var selection = await inventory.open_spell_scroll_menu()
	_active_menu.show()
	_block_input = false
	if selection != null:
		actor.learn_spell(selection, index)

func _on_player_menu_open_equipment_menu(actor: BattleActor) -> void:
	_block_input = true
	inventory.show()
	var selection = await inventory.open_equipment_menu()
	_active_menu.show()
	_block_input = false
	if selection != null:
		actor.equipment = selection
