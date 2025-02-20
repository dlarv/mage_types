extends Control

signal vendor_menu_closed

@export var main_menu: Control
@export var player_menu: Menu
@export var inventory: Menu
@export var matchup_chart: Menu
@export var settings_menu: Menu
@export var vendor_menu: Menu

var overworld: Node
var _active_menu: Menu = null

func _ready() -> void:
	overworld = get_tree().get_root().get_children()[-1].get_node("%Overworld")
	hide()

func _unhandled_input(input: InputEvent) -> void:
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

func open_vendor_menu(vendor: VendorActor) -> void:
	_active_menu = vendor_menu
	vendor_menu.open_menu(vendor)
	vendor_menu.show()

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
