@tool
extends Control 
class_name CharactersMenu 

@export
var activeScreensParent: TabContainer 
@export
var inactiveScreensParent: Control 

@export
var aliceScreen: CharacterScreen 
@export
var alexScreen: CharacterScreen 

@export
var statsToDistribute : int = 0

@export
var is_alice_active: bool = true:
	set(value):
		is_alice_active = value
		if activeScreensParent == null:
			activeScreensParent = find_child("ActiveTabs")
		if inactiveScreensParent == null: 
			inactiveScreensParent = find_child("InactiveTabs")
		if aliceScreen == null:
			aliceScreen = find_child("Alice", true)

		if value and inactiveScreensParent.is_ancestor_of(aliceScreen):
			aliceScreen.reparent(activeScreensParent)
		elif not value and activeScreensParent.is_ancestor_of(aliceScreen):
			aliceScreen.reparent(inactiveScreensParent)
@export
var is_alex_active: bool = true:
	set(value):
		is_alex_active = value
		if activeScreensParent == null:
			activeScreensParent = find_child("ActiveTabs")
		if inactiveScreensParent == null: 
			inactiveScreensParent = find_child("InactiveTabs")
		if alexScreen == null:
			alexScreen = find_child("Alex", true)

		if value and inactiveScreensParent.is_ancestor_of(alexScreen):
			alexScreen.reparent(activeScreensParent)
		elif not value and activeScreensParent.is_ancestor_of(alexScreen):
			alexScreen.reparent(inactiveScreensParent)
			


