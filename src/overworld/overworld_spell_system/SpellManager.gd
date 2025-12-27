extends Node3D

# signal spell_selected(is_primary: bool, spell: OverworldSpell)

@export var Projectile: PackedScene
@export var spell_mapper: Dictionary[Equipment, OverworldSpell]

var _spell: OverworldSpell

func _enter_tree() -> void:
	if not Inventory.overworld_spell_selected.is_connected(activate_spell):
		Inventory.overworld_spell_selected.connect(activate_spell)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast_spell_1") and _spell:
		_spell.perform_action()


func activate_spell(item: Equipment) -> void:
	if _spell:
		_spell.deactivate()

	_spell = spell_mapper.get(Inventory.active_spell)
	if _spell:
		_spell.activate()
		UIManager.show_overworld_spell(_spell)
	# var spell: OverworldSpell
	# match id:
	# 	OverworldSpell.Spells.STASIS: 
	# 		spell = stasis_spell
	# 	OverworldSpell.Spells.CATALYST: 
	# 		spell = catalyst_spell
	# 	OverworldSpell.Spells.DESTROY: 
	# 		spell = destroy_spell
	# 	OverworldSpell.Spells.SET_PORTAL: 
	# 		spell = set_portal_spell
	# 	OverworldSpell.Spells.USE_PORTAL: 
	# 		spell = use_portal_spell
	# 	OverworldSpell.Spells.GOLEM,_: 
	# 		spell = golem_spell
	# if isPrimary:
	# 	if active_spell_1 != null: active_spell_1.deactivate()
	# 	active_spell_1 = spell
	# 	spell_selected.emit(true, spell)
	# else:
	# 	if active_spell_2 != null: active_spell_2.deactivate()
	# 	active_spell_2 = spell
	# 	spell_selected.emit(false, spell)
	#
	# spell.set_primary(isPrimary)

