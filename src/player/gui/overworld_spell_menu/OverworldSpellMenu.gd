extends Control

@export var stasis_selector: HBoxContainer
@export var destroy_selector: HBoxContainer
@export var catalyst_selector: HBoxContainer
@export var vines_selector: HBoxContainer
@export var tunnel_selector: HBoxContainer

func _ready():
	var bg1 := ButtonGroup.new()
	var bg2 := ButtonGroup.new()
	stasis_selector.setup(bg1, bg2, Inventory.stasis_spell_enabled)
	destroy_selector.setup(bg1, bg2, Inventory.destroy_spell_enabled)
	catalyst_selector.setup(bg1, bg2, Inventory.catalyst_spell_enabled)
	vines_selector.setup(bg1, bg2, Inventory.vines_spell_enabled)
	tunnel_selector.setup(bg1, bg2, Inventory.tunnel_spell_enabled)
