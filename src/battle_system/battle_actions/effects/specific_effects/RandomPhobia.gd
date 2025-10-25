@tool
extends _AttackEffect 
class_name RandomPhobia

@export_range(1, 8) var min_count := 1
@export_range(1, 8) var max_count := 1

func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var msg := []
	var count := randi_range(min_count, max_count)
	var indices: Array[int] = range(0, 8)
	indices.shuffle()

	# Ensure no repeat effects.
	for i in count:
		var index: int = indices.pop_back()

		# Create effect.
		var e := ElementManager.elements[index]
		var phobia := PhobiaEffect.new()
		phobia.element = e

		# Apply effect.
		target.add_status_effect(phobia)
		phobia.apply_effect(data, target)

	return data


func get_setup_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> float:
	var output := 0.0

	var count := randi_range(min_count, max_count)
	for i in range(count):
		var phobia := PhobiaEffect.new()
		output += phobia.get_setup_potential(data, target, isFriendly)

	return output
