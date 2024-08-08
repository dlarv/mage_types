extends Node
class_name OpponentControl

signal attack_selected(attack: Attack, id: int)
signal actor_selected(actor: BattleActor.Fighter, id: int)

const ID: int = 1

## How often does this opponent attack vs switch. 
## 0.0 = Only switches
## 1.0 = Only attacks
@export_range(0.0, 1.0) var aggression: float

## How likely is the opponent to make the optimal decision.
## Higher values may increase the time taken to calculate decision.
@export_range(0.0, 1.0) var intelligence: float

# Decide which move the opponent will use
# Attack
# Switch
func _calculate_move(actor: BattleActor.Fighter, eam: Array, other: BattleActor.Fighter):
	pass
