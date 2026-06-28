extends Node3D

# signal spell_selected(is_primary: bool, spell: OverworldSpell)

@export var Projectile: PackedScene
@export var spell_mapper: Dictionary[Equipment, OverworldSpell]

var _spell: OverworldSpell

func _enter_tree() -> void:
	for spell in get_children():
		spell.deactivate()

	if not Inventory.overworld_spell_selected.is_connected(activate_spell):
		Inventory.overworld_spell_selected.connect(activate_spell)

	activate_spell(Inventory.active_spell)



func activate_spell(item: Equipment) -> void:
	if not item: return

	if _spell: 
		_spell.deactivate()

	_spell = spell_mapper.get(item)

	if _spell:
		_spell.activate()
		UIManager.show_overworld_spell(_spell)
