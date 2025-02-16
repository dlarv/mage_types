extends Control
class_name BattleActorDisplay 

signal status_effect_icon_pressed(effect)

@export var name_label: Label 
@export var health_bar: HSlider 
@export var hp_label: Label 
@export var status_effect_icons: Control 
@export var stat_change_display: StatChangeDisplay 
@export var selector_button: Button 

var actor: BattleActor 

var total_hp: float 
# Dict<string, Node>
var icons := {}

func setup(actor: BattleActor):
	name_label.text = actor.name
	health_bar.value = (float(actor.current_hp) / actor.hp) * 100
	hp_label.text = "%d/%d" % [actor.current_hp, actor.hp ]
	total_hp = actor.hp

	self.actor = actor

	actor.was_just_defeated.connect(set_defeated)
	actor.damage_applied.connect(set_health)
	#actor.status_effect_added.connect(add_status_effect)
	#actor.status_effects_removed.connect(remove_status_effects)
	actor.stat_manager.stat_changed.connect(display_stat_change)


func set_health(hp: int) -> void:
	health_bar.value = (float(hp) / total_hp) * 100.0
	hp_label.text = "%d/%d" % [ hp, total_hp ]

func get_target_position() -> Vector2:
	var position = global_position
	position.x += size.x / 2
	position.y += size.y / 2
	return position


# func add_status_effect(effect: StatusEffect) -> void:
# 	var key := effect.name
# 	if effect.name == StatusEffectManager.PHOBIC_KEY:
# 		key = "%s_%s" % [effect.element, StatusEffectManager.PHOBIC_KEY]
#
# 	if(icons.has(key)): return
#
# 	var icon = effect.instantiate_icon()
# 	status_effect_icons.add_child(icon)
# 	icons[key] = icon
#
# 	var button = icon.get_node("Button")
# 	button.pressed.connect(func(): status_effect_icon_pressed.emit(effect))
#
#
# func remove_status_effects(effects) -> void:
# 	for effect in effects:
# 		if !icons.has(effect.name): continue
# 		var icon = icons[effect.name]
# 		status_effect_icons.remove_child(icon)
# 		icons.erase(effect.name)
		
func display_stat_change(stat: StatManager.Stat, value: float) -> void:
	stat_change_display.add(stat, value)

func set_defeated() -> void:
	modulate = Color(1, 1, 1, .5)
	for key in icons.keys():
		var icon = icons[key]
		status_effect_icons.remove_child(icon)
	icons.clear()
