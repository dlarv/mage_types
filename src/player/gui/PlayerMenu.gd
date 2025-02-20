extends Menu

@export var inventory_screen: InventoryScreen 
@export var characters_menu: CharactersMenu
@export var spell_menu: Control

func _ready():
	if Engine.is_editor_hint(): return
	# if not (Inventory.stasis_spell_enabled \
	# 		and Inventory.destroy_spell_enabled \
	# 		and Inventory.vines_spell_enabled \
	# 		and Inventory.catalyst_spell_enabled \
	# 		and Inventory.tunnel_spell_enabled):
	# 			spell_menu.hide()

