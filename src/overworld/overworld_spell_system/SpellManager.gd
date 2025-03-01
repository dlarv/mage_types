extends Node3D

signal spell_selected(is_primary: bool, spell: OverworldSpell)

@export var Projectile: PackedScene

@export var stasis_spell: OverworldSpell
@export var destroy_spell: OverworldSpell
@export var catalyst_spell: OverworldSpell
@export var vines_spell: OverworldSpell
@export var tunnel_spell: OverworldSpell
@export var primary_override: OverworldSpell.Spells
@export var secondary_override: OverworldSpell.Spells
@export var use_override: bool


var active_spell_1: OverworldSpell
var active_spell_2: OverworldSpell

func _ready():
	Inventory.overworld_spell_selected.connect(activate_spell)
	stasis_spell.Projectile = Projectile
	destroy_spell.Projectile = Projectile
	catalyst_spell.Projectile = Projectile
	vines_spell.Projectile = Projectile
	tunnel_spell.Projectile = Projectile

	spell_selected.connect(UIManager.hud.show_overworld_spell)

	if use_override:
		activate_spell(primary_override, true)
		activate_spell(secondary_override, false)
	


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

	
