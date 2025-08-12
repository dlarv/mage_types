@tool
extends Resource
class_name BattleTalk 

@export var turn: int
@export var id: String
# Display after all the actions have resolved.
@export var displayAfterTurn: bool
@export var repeat := false
## Used to allow speaker to set story variables based on player's actions/etc.
## Values will be added as needed.
@export_enum("player_spell_element", "none") 
var battle_story_interface: String = "none"


func init_story_interface(user: BattleActor) -> void:
	match battle_story_interface:
		"player_spell_element":
			for actor:BattleActor in Battle.query_battlefield_state(user, Battle.BattlefieldStateParams.TEAM_0):
				if actor.id == 1 and not actor.action_used.is_connected(_player_spell_element):
					actor.action_used.connect(_player_spell_element)


func _player_spell_element(action: _BattleAction) -> void:
	StoryManager.set_variable("misc_battle_data", action.element.name.to_lower())
