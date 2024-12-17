extends AttackEffect 
class_name RandomPhobia

@export var Phobia: StatusEffect
@export_range(1, 8) var min_count := 1
@export_range(1, 8) var max_count := 1

func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0, element:ElementalType=ElementManager.Blank) -> String:
	var msg := []
	var count = randi_range(min_count, max_count)
	var indices := range(0, 8)
	indices.shuffle()

	# Ensure no repeat effects.
	for i in range(count):
		var index = indices.pop_back()

		# Create effect.
		var e = ElementManager.elements[index]
		var phobia = Phobia.duplicate()
		phobia.element = e

		# Apply effect.
		target.add_status_effect(phobia)
		msg.append(phobia.apply_effect(user, target, action))

	return "\n".join(msg)

func get_setup_potential(user: BattleActor, target: BattleActor) -> float:
	return 1
