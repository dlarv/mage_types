extends "_Bubble.gd"


func setup(actorEffectPair: Variant) -> void:
	%NameLabel.text = str(actorEffectPair[0].name)
	%EffectLabel.text = str(BattleActor.StatusEffectManager.StatusEffects.keys()[actorEffectPair[1].id])
