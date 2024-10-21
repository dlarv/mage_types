@tool
extends Resource
class_name BattleTalk 

@export var turn: int
@export var id: String
# Display after all the actions have resolved.
@export var displayAfterTurn: bool
@export var repeat := false
