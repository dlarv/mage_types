extends "_Bubble.gd"


# data: ActorTurnData
func setup(data: Variant) -> void:
	%AttackLabel.text = data.action.name
	%TargetLabel.text = ",".join(data.targets.map(func(x: BattleActor) -> String: return x.name))
