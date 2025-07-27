@tool
extends _AttackEffect 
class_name RandomPhobia

@export_range(1, 8) var min_count := 1
@export_range(1, 8) var max_count := 1

func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
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
		msg.append(phobia.apply_effect(user, target))

	return "\n".join(msg)

func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	var output := 0.0

	var count := randi_range(min_count, max_count)
	for i in range(count):
		var phobia := PhobiaEffect.new()
		output += phobia.get_setup_potential(user, target, isFriendly, 0)

	return output
