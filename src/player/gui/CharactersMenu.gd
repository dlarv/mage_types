@tool
extends Control 
class_name CharactersMenu 

@export var active_screens_parent: TabContainer 
@export var inactive_screens_parent: Control 

@export var player_screen: CharacterScreen
@export var alice_screen: CharacterScreen 
@export var alex_screen: CharacterScreen 

@export var stats_to_distribute : int = 0

@export
var is_alice_active: bool = true:
	set(value):
		is_alice_active = value
		if active_screens_parent == null:
			active_screens_parent = find_child("ActiveTabs")
			if active_screens_parent == null: return
		if inactive_screens_parent == null: 
			inactive_screens_parent = find_child("InactiveTabs")
			if inactive_screens_parent == null: return
		if alice_screen == null:
			alice_screen = find_child("Alice", true)

		if value and inactive_screens_parent.is_ancestor_of(alice_screen):
			alice_screen.reparent(active_screens_parent)
		elif not value and active_screens_parent.is_ancestor_of(alice_screen):
			alice_screen.reparent(inactive_screens_parent)
@export
var is_alex_active: bool = true:
	set(value):
		is_alex_active = value
		if active_screens_parent == null:
			active_screens_parent = find_child("ActiveTabs")
			if active_screens_parent == null: return
		if inactive_screens_parent == null: 
			inactive_screens_parent = find_child("InactiveTabs")
			if inactive_screens_parent == null: return
		if alex_screen == null:
			alex_screen = find_child("Alex", true)

		if value and inactive_screens_parent.is_ancestor_of(alex_screen):
			alex_screen.reparent(active_screens_parent)
		elif not value and active_screens_parent.is_ancestor_of(alex_screen):
			alex_screen.reparent(inactive_screens_parent)
			


