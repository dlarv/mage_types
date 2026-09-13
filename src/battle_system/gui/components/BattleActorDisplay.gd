extends Control

const StatChangeDisplay := preload("res://src/battle_system/gui/components/stat_display/StatChangeDisplay.gd")

@export var stat_change_display: StatChangeDisplay 

var actor: BattleActor 
var total_hp: float 
var current_hp: float
var next_hp: float

func setup(actor: BattleActor) -> void:
	%NameLabel.text = "%s (lvl%d)" % [ actor.name, actor.level ]

	%HSlider.value = (float(actor.current_hp) / actor.hp) * 100
	%HpLabel.text = "%d/%d" % [ actor.current_hp, actor.hp ]
	total_hp = actor.hp
	current_hp = actor.hp
	next_hp = -1

	self.actor = actor
	%Element1.color = actor.element1.main_color
	%Element2.color = actor.element2.main_color

	actor.was_just_defeated.connect(set_defeated)
	actor.damage_applied.connect(set_health)
	actor.stat_manager.stat_changed.connect(display_stat_change)
	actor.element_changed.connect(change_element)
	actor.status_activated.connect(_on_status_activated)


func _exit_tree() -> void:
	actor.was_just_defeated.disconnect(set_defeated)
	actor.damage_applied.disconnect(set_health)
	actor.stat_manager.stat_changed.disconnect(display_stat_change)
	actor.element_changed.disconnect(change_element)
	actor.status_activated.disconnect(_on_status_activated)
	

func set_health(hp: int) -> void:
	next_hp = hp


func animate_hp() -> void:
	if next_hp < 0: return

	const DURATION := 0.5
	var tween := get_tree().create_tween()
	var endVal := (next_hp / total_hp) * 100.0
	var startVal := (current_hp / total_hp) * 100.0

	tween.tween_property(%HSlider, "value", endVal, DURATION)
	tween.set_parallel()
	tween.tween_method(
		func(val: int) -> void: 
			%HpLabel.text = "%d/%d" % [ val * total_hp / 100, total_hp ], 
		startVal, 
		endVal, 
		DURATION
	)

	current_hp = next_hp
	next_hp = -1
	await tween.finished
	%HpLabel.text = "%d/%d" % [ current_hp, total_hp ] 



func display_stat_change(stat: StatManager.Stats, value: float) -> void:
	stat_change_display.add(stat, value)


func set_defeated() -> void:
	modulate = Color(1, 1, 1, .5)
	next_hp = 0
	animate_hp()


func change_element(id: int, e: ElementalType) -> void:
	if id == 0:
		%Element1.color = e.main_color
	else:
		%Element2.color = e.main_color


 
func _on_status_activated(effect: StatusEffect, data: Variant) -> void:
	match effect.id:
		StatusEffect.Effects.POISON,StatusEffect.Effects.PHOBIC:
			animate_hp()
