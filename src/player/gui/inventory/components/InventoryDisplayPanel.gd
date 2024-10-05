@tool
extends Control 
class_name InventoryDisplayPanel 

func display(item: Item) -> void:
	if item is Equipment: format_equipment(item);
	elif item is KeyItem: format_key_item(item);
	elif item is SpellScroll: format_spell_scroll(item);
	elif item is Item: format_item(item);

func format_equipment(item: Equipment) -> void:
	pass
func format_key_item(item: KeyItem) -> void:
	pass
func format_spell_scroll(item: SpellScroll) -> void:
	pass
func format_item(item: Item) -> void:
	pass
