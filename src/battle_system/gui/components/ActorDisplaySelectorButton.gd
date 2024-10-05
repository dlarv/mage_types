extends Button

@export var TransmutationHint: PackedScene

var actor: BattleActor
# Is null when BattleActor is not selectable by player.
# Otherwise, stores the element of the attack the player is selecting the target for.
var attack_element: ElementalType = null
var is_selectable := false

func _make_custom_tooltip(for_text):
	if attack_element == null: return null

	var tooltip = TransmutationHint.instantiate()
	tooltip.setup(actor, attack_element)
	return tooltip

func set_selectable(value: bool):
	visible = value
	is_selectable = value

func set_show_hint(value: bool, element: ElementalType=null):
	visible = value
	attack_element = element
