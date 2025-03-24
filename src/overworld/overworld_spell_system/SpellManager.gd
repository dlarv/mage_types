extends Node3D

signal spell_selected(is_primary: bool, spell: OverworldSpell)

@export var Projectile: PackedScene

@export var stasis_spell: OverworldSpell
@export var destroy_spell: OverworldSpell
@export var catalyst_spell: OverworldSpell
@export var vines_spell: OverworldSpell
@export var tunnel_spell: OverworldSpell

var active_spell_1: OverworldSpell
var active_spell_2: OverworldSpell

func _enter_tree():
	if not Inventory.overworld_spell_selected.is_connected(activate_spell):
		Inventory.overworld_spell_selected.connect(activate_spell)
	stasis_spell.Projectile = Projectile
	destroy_spell.Projectile = Projectile
	catalyst_spell.Projectile = Projectile
	vines_spell.Projectile = Projectile
	tunnel_spell.Projectile = Projectile

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast_spell_1") and active_spell_1:
		active_spell_1.perform_action()
	if event.is_action_pressed("cast_spell_2") and active_spell_2:
		active_spell_2.perform_action()

func activate_spell(id: OverworldSpell.Spells, isPrimary: bool) -> void:
	var spell
	match id:
		OverworldSpell.Spells.STASIS: 
			spell = stasis_spell
		OverworldSpell.Spells.CATALYST: 
			spell = catalyst_spell
		OverworldSpell.Spells.DESTROY: 
			spell = destroy_spell
		OverworldSpell.Spells.VINES: 
			spell = vines_spell
		_: 
			spell = tunnel_spell
	if isPrimary:
		if active_spell_1 != null: active_spell_1.deactivate()
		active_spell_1 = spell
		spell_selected.emit(true, spell)
	else:
		if active_spell_2 != null: active_spell_2.deactivate()
		active_spell_2 = spell
		spell_selected.emit(false, spell)

	spell.set_primary(isPrimary)
	UIManager.show_overworld_spell(isPrimary, spell)
