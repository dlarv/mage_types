@tool
extends EquipmentTrigger
class_name StatusEffectTrigger

## If null, acts as a wildcard
@export var status_effect: StatusEffect
@export var activate_on_removal := false

#override
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if not actor.status_effect_added.is_connected(_on_status_effect_added):
		actor.status_effect_added.connect(_on_status_effect_added)
	if not actor.status_effects_removed.is_connected(_on_status_effect_removed):
		actor.status_effect_added.connect(_on_status_effect_removed)


#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if actor.status_effect_added.is_connected(_on_status_effect_added):
		actor.status_effect_added.disconnect(_on_status_effect_added)
	if actor.status_effects_removed.is_connected(_on_status_effect_removed):
		actor.status_effect_added.disconnect(_on_status_effect_removed)

func _on_status_effect_added(effect: StatusEffect) -> void:
	if activate_on_removal: return
	if status_effect != null and effect != status_effect: return
	activated.emit("")

func _on_status_effect_removed(effects: Array) -> void:
	if not activate_on_removal: return
	if len(effects) == 0: return

	if status_effect == null:
		activated.emit("")
		return

	for effect in effects:
		if status_effect == effect:
			activated.emit("")
	

