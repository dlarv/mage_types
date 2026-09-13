extends MarginContainer

signal next(skip: bool)

const Stats := StatManager.Stats
const DELAY := 1.0

var tween: Tween
var _actor: PlayerBattleActor

func _ready() -> void:
	if tween and not tween.finished.is_connected(_next):
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
	if actor.stat_manager is PlayerStatManager:
		%XpSlider.value = actor.get_xp_percentage()
	%Level.text = "Lv%d" % actor.level


func add_xp(amount: float) -> void:
	var start_xp: float = _actor.get_xp_percentage()
	var levels := _actor.add_xp(amount)
	var finish_xp: float = _actor.get_xp_percentage()

	var stats: Dictionary[Stats, float] = _actor.level_up(levels)

	if levels == 0:
		await _animate_xp_bar(start_xp, finish_xp)
	elif levels == 1:
		await _animate_xp_bar(start_xp, 1.0)
	else:
		await _animate_xp_bar(start_xp, 1.0)
		for level in levels:
			await _animate_xp_bar(0, 1, 1/float(level))
		await _animate_xp_bar(0, finish_xp)

	if levels == 0: return

	%Level.text = "Lv%d +%d" % [_actor.level, levels]
	%MeleeAttack.text += " +%d" % int(stats[Stats.MELEE_ATTACK])
	%MeleeDefense.text += " +%d" % int(stats[Stats.MELEE_DEFENSE])
	%RangedAttack.text += " +%d" % int(stats[Stats.RANGED_ATTACK])
	%RangedDefense.text += " +%d" % int(stats[Stats.RANGED_DEFENSE])
	%Hp.text += " +%d" % int(stats[Stats.HP])
	%Speed.text += " +%d" % int(stats[Stats.SPEED])


func _next(skip:=false) -> void:
	if tween:
		tween.stop()
	next.emit(skip)


func _animate_xp_bar(start: float, end: float, delay_mod:=1.0) -> void:
	%XpSlider.max_value = 1.0

	%XpSlider.value = start
	var tween := create_tween()
	tween.tween_property(%XpSlider, "value", end, DELAY * delay_mod)
	tween.play()
	await next
