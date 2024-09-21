@tool
extends Control 
class_name InventoryDisplayPanel 

func Display(item: Item) -> void:
	if item is Equipment: FormatEquipment(item);
	elif item is KeyItem: FormatKeyItem(item);
	elif item is SpellScroll: FormatSpellScroll(item);
	elif item is Item: FormatItem(item);

func FormatEquipment(item: Equipment):
	pass
func FormatKeyItem(item: KeyItem) -> void:
	pass
func FormatSpellScroll(item: SpellScroll) -> void:
	pass
func FormatItem(item: Item) -> void:
	pass
