extends MarginContainer

var rows := {
	OverworldSpell.Spells.STASIS: [],
	OverworldSpell.Spells.CATALYST: [],
	OverworldSpell.Spells.DESTROY: [],
	OverworldSpell.Spells.VINES: [],
	OverworldSpell.Spells.TUNNEL: [],
}

func _ready() -> void:
	# Downstream, a method is called on UIManager.hud.
	# As this is not a singleton, it will not be ready until after this object.
	# Putting the await clause in the UIManager.hud method will cause it to hang after setup is complete.
	# This is the next best place to put it.
	await UIManager.ready
	if not Inventory.use_override: return
	_activate_spell(true, Inventory.primary_override, true)
	_activate_spell(true, Inventory.secondary_override, false)


func setup() -> void:
	Inventory.overworld_spell_enabled.connect(_on_overworld_spell_enabled)
	for child in $GridContainer.get_children():
		if child.name.contains("Header"): continue

		var id 
		if child.name.contains("Stasis"):
			id = OverworldSpell.Spells.STASIS
		elif child.name.contains("Catalyst"):
			id = OverworldSpell.Spells.CATALYST
		elif child.name.contains("Destroy"):
			id = OverworldSpell.Spells.DESTROY
		elif child.name.contains("Vines"):
			id = OverworldSpell.Spells.VINES
		else:
			id = OverworldSpell.Spells.TUNNEL

		rows[id].append(child)
		if child is CheckBox:
			var isPrimary := child.name.contains("1")
			child.toggled.connect(_activate_spell.bind(id, isPrimary))

			if Inventory.use_override and Inventory.primary_override == id and isPrimary:
				child.set_pressed_no_signal(true)
				#_activate_spell(true, id, true)
			if Inventory.use_override and Inventory.secondary_override == id and not isPrimary:
				child.set_pressed_no_signal(true)
				#_activate_spell(true, id, false)
	
	_on_overworld_spell_enabled(OverworldSpell.Spells.STASIS, Inventory.stasis_spell_enabled)
	_on_overworld_spell_enabled(OverworldSpell.Spells.CATALYST, Inventory.catalyst_spell_enabled)
	_on_overworld_spell_enabled(OverworldSpell.Spells.DESTROY, Inventory.destroy_spell_enabled)
	_on_overworld_spell_enabled(OverworldSpell.Spells.VINES, Inventory.vines_spell_enabled)
	_on_overworld_spell_enabled(OverworldSpell.Spells.TUNNEL, Inventory.tunnel_spell_enabled)
	
func _on_overworld_spell_enabled(spell: OverworldSpell.Spells, val: bool) -> void:
	for child in rows[spell]:
		child.visible = val

func _activate_spell(toggledOn: bool, spell: OverworldSpell.Spells, isPrimary: bool) -> void:
	if toggledOn:
		Inventory.select_overworld_spell(spell, isPrimary)

func set_primary(id: OverworldSpell.Spells) -> void:
	rows[id][1].button_group.get_pressed_button().set_pressed_no_signal(false)
	rows[id][1].set_pressed_no_signal(true)
	_activate_spell(true, id, true)

func set_secondary(id: OverworldSpell.Spells) -> void:
	rows[id][2].button_group.get_pressed_button().set_pressed_no_signal(false)
	rows[id][2].set_pressed_no_signal(true)
	_activate_spell(true, id, false)
