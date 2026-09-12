extends VBoxContainer

const TurnOrderItem := preload("res://src/battle_system/gui/components/turn_order_display/TurnOrderItem.gd")

# Value used by Battle to break speed ties
var _tie_breaker: bool


func update_turn_order(data: Dictionary[BattleActor, ActorTurnData]) -> void:
	var actions := data.values()
	actions.sort_custom(ActorTurnData.sort.bind(_tie_breaker))

	for child in %VBoxContainer.get_children(): %VBoxContainer.remove_child(child)

	for action: ActorTurnData in actions:
		if action == null: continue
		var actor_name := ""
		if action.user != null:
			actor_name = action.user.name
			
		var element: ElementalType
		if action.action != null:
			if action.team_index == 1 and not Settings.show_opponent_intentions:
				element = ElementManager.Blank
			else:
				element = action.action.element
			
		var item := TurnOrderItem.new(actor_name, element)
		%VBoxContainer.add_child(item)


func set_tie_breaker(tie_breaker: float) -> void:
	_tie_breaker = tie_breaker
