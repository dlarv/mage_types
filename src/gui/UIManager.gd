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
@export var golem_menu: Menu
@export var catalyst_menu: Menu
@export var map_menu: Menu
@export var beastiary_menu: Menu

@onready var info_graphics := {
	"stasis": $PanelContainer/MarginContainer/TabContainer/StasisOverworldSpell,
	"catalyst": $PanelContainer/MarginContainer/TabContainer/CatalystTutorial,
}

## In battle, player can only open the matchup menu
var in_battle_mode := false

var overworld: Node
var dialog_box: DialogueBox
var hud: CanvasLayer
var _menu_stack: Array[Control] = []
var is_in_dialog := false
var block_input := false


func _ready() -> void:
	# block_input = true
	hide()


func setup() -> void:
	var root := get_tree().get_current_scene()
	overworld = root.get_node("%Overworld")
	dialog_box = root.get_node("%DialogueBox")
	hud = root.get_node("%HUD_Layer")
	block_input = false

	save_menu.setup()
	var p := get_tree().get_first_node_in_group("player") 
	player_menu.setup(p)


func _unhandled_input(input: InputEvent) -> void:
	if block_input: 
		if not inventory.visible: return
		if input.is_action_pressed("ui_cancel"):
			inventory.spell_scroll_selected.emit(null)
			inventory.equipment_selected.emit(null)
	elif in_battle_mode:
		if input.is_action_pressed("open_transmutation_menu"):
			push_menu(matchup_chart)
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
	elif input.is_action_pressed("open_map_menu"):
		push_menu(map_menu)


func push_menu(menu: Control) -> void:
	get_tree().paused = true
	if len(_menu_stack) > 0 and menu == _menu_stack[-1]:
		pop_menu()
		return
	menu.show()
	_menu_stack.append(menu)
	show()


func pop_menu() -> void:
	var menu: Control = _menu_stack.pop_back()
	if menu:
		menu.hide()
	if len(_menu_stack) == 0:
		# overworld.process_mode = Node.PROCESS_MODE_INHERIT
		# This helps if player has opened menu while talking to an NPC.
		get_tree().paused = is_in_dialog and not in_battle_mode
		hide()
	else:
		_menu_stack[-1].show()


func clear_all() -> void:
	for menu: Menu in _menu_stack:
		menu.hide()
	hide()
	_menu_stack = []
	get_tree().paused = is_in_dialog


func show_dialog(msg: String) -> void:
	# Gets empty dialog box attached to MISC start node.
	dialog_box.show_text(msg)
	# dialog_box.data.nodes[dialog_box.data.nodes[dialog_box.data.starts["MISC"]]["link"]].dialogue = msg
	is_in_dialog = true
	get_tree().paused = true
	# dialog_box.start("MISC")
	await dialog_box.dialogue_ended
	is_in_dialog = false
	get_tree().paused = false


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


func show_overworld_spell(spell: OverworldSpell) -> void:
	# Without this block, overworld spells cannot show their icon upon startup.
	if not hud:
		var root := get_tree().get_current_scene()
		hud = root.get_node("%HUD_Layer")
		# Needed when playing non-main scene
		if not hud: return
	hud.show_overworld_spell(spell)


func show_info_graphic(key: String) -> void:
	if info_graphics.has(key):
		var graphic: Menu = info_graphics[key]
		push_menu(graphic)
		await graphic.info_graphic_closed
		pop_menu()
	else:
		push_warning("No info graphic with Key(%s) found." % key)


func toggle_transmutation_menu() -> void:
	if len(_menu_stack) > 0 and _menu_stack[-1] == matchup_chart:
		_menu_stack.pop_back()
		matchup_chart.hide()
		hide()
	else:
		_menu_stack.append(matchup_chart)
		matchup_chart.show()
		show()


func restrict_transmutation_menu(elements: Array[ElementalType]) -> void:
	matchup_chart.restrict_graph(elements)


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


func _on_map_button_pressed() -> void:
	push_menu(map_menu)


func _on_beastiary_button_pressed() -> void:
	push_menu(beastiary_menu)


func toggle_golem_menu(element: ElementalType=null) -> void:
	golem_menu.element = element
	push_menu(golem_menu)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_vendor_menu_menu_closed() -> void:
	_menu_stack.pop_back()
	vendor_menu_closed.emit()
	vendor_menu.hide()


func _on_player_menu_open_spell_menu(index: int, actor: BattleActor) -> void:
	block_input = true
	inventory.show()
	var selection: _Item = await inventory.open_spell_scroll_menu()
	_menu_stack[-1].show()
	block_input = false

	if selection != null:
		Inventory.remove(selection, 1)
		actor.replace_attack(selection, index)


func _on_player_menu_open_equipment_menu(index: int, actor: BattleActor) -> void:
	block_input = true
	inventory.show()
	var selection: _Item = await inventory.open_equipment_menu(index != -1)
	_menu_stack[-1].show()
	block_input = false

	if selection == null: return

	Inventory.remove(selection, 1)
	if index == -1:
		actor.equipment = selection
	elif selection.has_overworld_use:
		Inventory.active_spell = selection
	else:
		push_warning("%s cannot be selected as overworld spell")


func _on_main_menu_button_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://src/gui/main_menu/main_menu.tscn")


func _on_catalyst_menu_closed(element:ElementalType) -> void:
	_menu_stack.pop_back()
	catalyst_menu.hide()
	catalyst_menu_closed.emit(element)
	hide()


func reload() -> void:
	pass
