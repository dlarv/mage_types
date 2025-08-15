extends MarginContainer

signal next(skip: bool)

const Stats := StatManager.Stats
const DELAY := 1.0

var tween: Tween
var _actor: BattleActor

func _ready() -> void:
	tween = create_tween()
	if not tween.finished.is_connected(_next):
		tween.finished.connect(_next)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_next(true)


func set_actor(actor: BattleActor) -> void:
	_actor = actor

	%NameLabel.text = actor.name
	%Hp.text = str(actor.get_stat(Stats.HP))
	%MeleeAttack.text = str(actor.get_stat(Stats.MELEE_ATTACK))
	%MeleeDefense.text = str(actor.get_stat(Stats.MELEE_DEFENSE))
	%RangedAttack.text = str(actor.get_stat(Stats.RANGED_ATTACK))
	%RangedDefense.text = str(actor.get_stat(Stats.RANGED_DEFENSE))
	%Speed.text = str(actor.get_stat(Stats.SPEED))
	%XpSlider.value = int(actor.stat_manager.total_xp / actor.stat_manager.next_level_xp)
	%Level.text = "Lv%d" % actor.level


func add_xp(amount: float) -> void:
	var levels := _actor.add_xp(amount)
	if levels == 0: return
	var stats: Dictionary[Stats, float] = _actor.level_up(levels)

	tween.tween_property(%XpSlider, "value", int(_actor.stat_manager.total_xp / _actor.stat_manager.next_level_xp * 100), DELAY)
	tween.play()
	await next

	%XpSlider.value = int(_actor.stat_manager.total_xp / _actor.stat_manager.next_level_xp * 100)
	if levels == 0: return

	%Level.text = "Lv%d +%d" % [_actor.level, levels]
	%MeleeAttack.text += " +%d" % int(stats[Stats.MELEE_ATTACK])
	%MeleeDefense.text += " +%d" % int(stats[Stats.MELEE_DEFENSE])
	%RangedAttack.text += " +%d" % int(stats[Stats.RANGED_ATTACK])
	%RangedDefense.text += " +%d" % int(stats[Stats.RANGED_DEFENSE])
	%Hp.text += " +%d" % int(stats[Stats.HP])
	%Speed.text += " +%d" % int(stats[Stats.SPEED])


func _next(skip:=false) -> void:
	tween.stop()
	next.emit(skip)
