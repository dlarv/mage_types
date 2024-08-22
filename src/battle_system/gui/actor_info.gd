extends Control

@export var name_label: Label
@export var health_bar: HSlider
@export var hp_label: Label
@export var sprite: TextureRect

func set_display(actor):
	name_label.text = actor.actor_name
	health_bar.value = (actor.current_hp / actor.hp) * 100
	hp_label.text = "%d/%d" % [ actor.current_hp, actor.hp ]
