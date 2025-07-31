extends MarginContainer

const Stats := StatManager.Stats
const DELAY := 1.0

var _actor: BattleActor

func set_actor(actor: BattleActor) -> void:
	_actor = actor

	%NameLabel.text = actor.name
	%Hp.text = str(actor.get_stat(Stats.HP))
	%MeleeAttack.text = str(actor.get_stat(Stats.MELEE_ATTACK))
	%MeleeDefense.text = str(actor.get_stat(Stats.MELEE_DEFENSE))
	%RangedAttack.text = str(actor.get_stat(Stats.RANGED_ATTACK))
	%RangedDefense.text = str(actor.get_stat(Stats.RANGED_DEFENSE))
	%Speed.text = str(actor.get_stat(Stats.SPEED))
	%XpSlider.value = int(actor.total_xp / actor.next_level_xp)
	%Level.text = str(actor.level)


func add_xp(amount: float) -> void:
	var tween := get_tree().create_tween()
	var levels := _actor.add_xp(amount)
	tween.tween_property(%XpSlider, "value", int(_actor.total_xp), DELAY)
	await tween.finished

	if levels == 0: return

	%Level.text += " +%d" % levels
	var stats: Dictionary[Stats, float] = _actor.level_up(levels)
	%MeleeAttack.text += " +%d" % int(stats[Stats.MELEE_ATTACK])
	%MeleeDefense.text += " +%d" % int(stats[Stats.MELEE_DEFENSE])
	%RangedAttack.text += " +%d" % int(stats[Stats.RANGED_ATTACK])
	%RangedDefense.text += " +%d" % int(stats[Stats.RANGED_DEFENSE])
	%Hp.text += " +%d" % int(stats[Stats.HP])
	%Speed.text += " +%d" % int(stats[Stats.SPEED])
