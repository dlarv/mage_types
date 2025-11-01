extends Control

const StatChangeDisplay := preload("res://src/battle_system/gui/components/stat_display/StatChangeDisplay.gd")

@export var stat_change_display: StatChangeDisplay 

var actor: BattleActor 
var total_hp: float 

func setup(actor: BattleActor) -> void:
	%NameLabel.text = "%s (lvl%d)" % [ actor.name, actor.level ]
	%HSlider.value = (float(actor.current_hp) / actor.hp) * 100
	%HpLabel.text = "%d/%d" % [ actor.current_hp, actor.hp ]
	total_hp = actor.hp

	self.actor = actor
	%Element1.color = actor.element1.main_color
	%Element2.color = actor.element2.main_color

	actor.was_just_defeated.connect(set_defeated)
	actor.damage_applied.connect(set_health)
	actor.stat_manager.stat_changed.connect(display_stat_change)
	actor.element_changed.connect(func(id: int, e: ElementalType) -> void:
		if id == 0:
			%Element1.color = e.main_color
		else:
			%Element2.color = e.main_color
	)


func set_health(hp: int) -> void:
	%HSlider.value = (float(hp) / total_hp) * 100.0
	%HpLabel.text = "%d/%d" % [ hp, total_hp ]


func display_stat_change(stat: StatManager.Stats, value: float) -> void:
	stat_change_display.add(stat, value)


func set_defeated() -> void:
	modulate = Color(1, 1, 1, .5)
