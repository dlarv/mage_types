extends Node2D

var ActorInfo = preload("res://src/battle_system/gui/actor_info.tscn")

@export var allies_parent: HBoxContainer
@export var opponents_parent: HBoxContainer
@export var player_control: Control

var active_ally
var opponent_ai
var player_actions_queue

func start_battle(allies, opponents, opponent_ai):
	# Init actor sprites and health bars.
	# Populate player control with attacks and items.

	# Init Battle object
	pass

func _on_attack_selected(actor_index, attack):
	pass

func _on_item_selected(actor_index, item):
	pass

func _on_end_turn_button_pressed():
	pass
