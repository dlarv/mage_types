extends Control
class_name BattleActorDisplay 

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
	actor.stat_manager.stat_changed.connect(display_stat_change)



func set_health(hp: int) -> void:
	health_bar.value = (float(hp) / total_hp) * 100.0
	hp_label.text = "%d/%d" % [ hp, total_hp ]

func get_target_position() -> Vector2:
	var position = global_position
	position.x += size.x / 2
	position.y += size.y / 2
	return position

func display_stat_change(stat: StatManager.Stats, value: float) -> void:
	stat_change_display.add(stat, value)

func set_defeated() -> void:
	modulate = Color(1, 1, 1, .5)
	for key in icons.keys():
		var icon = icons[key]
		status_effect_icons.remove_child(icon)
	icons.clear()
