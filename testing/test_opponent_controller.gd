extends GutTest

class TestSetupPotential extends GutTest:
	var user: BattleActor
	var target: BattleActor


	func before_each() -> void:
		user = autofree(load("res://testing/user_battle_actor.tres").duplicate())
		target = autofree(load("res://testing/target_battle_actor.tres").duplicate())


	func test_instant_health_change_no_overflow() -> void:
		var effect: InstantHealthChange = autofree(InstantHealthChange.new())
		effect.allow_overflow = false

		var expected := 0.5
		effect.strength = 0.5

		assert_eq(effect.get_setup_potential(user, target, true, 100), 0.0)
		assert_eq(effect.get_setup_potential(user, target, false, 100), 0.0)

		target.current_hp = 75
		assert_eq(effect.get_setup_potential(user, target, true, 100), 0.25)
		assert_eq(effect.get_setup_potential(user, target, false, 100), -0.25)


	func test_instant_health_change_with_overflow() -> void:
		var effect: InstantHealthChange = autofree(InstantHealthChange.new())
		effect.allow_overflow = true

		var expected := 0.5
		effect.strength = 0.5

		assert_eq(effect.get_setup_potential(user, target, true, 100), expected)
		assert_eq(effect.get_setup_potential(user, target, false, 100), -expected)

		target.current_hp = 1
		assert_eq(effect.get_setup_potential(user, target, true, 100), expected)
		assert_eq(effect.get_setup_potential(user, target, false, 100), -expected)


	func test_stat_buff() -> void:
		var effect: StatChange = autofree(StatChange.new())
		effect.strength = 0.3

		# The more stat buffs your ally has, the less setup potential.
		var a := effect.get_setup_potential(user, target, true, 0)
		target.add_status_effect(effect)
		var b := effect.get_setup_potential(user, target, true, 0)
		assert_gt(a, b)

		a = effect.get_setup_potential(user, target, false, 0)
		target.add_status_effect(effect)
		b = effect.get_setup_potential(user, target, false, 0)
		assert_eq(a, b)
		assert_eq(a, -1.0)


	func test_stat_debuff() -> void:
		var effect: StatChange = autofree(StatChange.new())
		effect.strength = -0.3

		var a := effect.get_setup_potential(user, target, true, 0)
		assert_eq(a, -1.0)

		# If stat mod is maxed out (positive or negative), any further buffs are considered neglible.
		effect.strength = 100
		target.add_status_effect(effect)
		effect.strength = -0.3
		var b := effect.get_setup_potential(user, target, true, 0)
		assert_eq(b, 0.0)


		var c := effect.get_setup_potential(user, target, false, 0)
		assert_eq(c, 1.0)

	
	func test_stasis_effect() -> void:
		var effect: StatusEffect = autofree(StatusEffect.new())
		effect.id = StatusEffectManager.StatusEffects.STASIS

		var woPhobia := effect.get_setup_potential(user, target, true, 0)
		assert_eq(woPhobia, 0.0)
		woPhobia = effect.get_setup_potential(user, target, false, 0)
		assert_eq(woPhobia, 0.0)

		# Stasis only cares about whether target has stasis.
		var phobia := PhobiaEffect.new()
		phobia.element = ElementManager.Blue
		target.add_status_effect(phobia)

		var wPhobia := effect.get_setup_potential(user, target, true, 0)
		assert_eq(wPhobia, 1.0)

		wPhobia = effect.get_setup_potential(user, target, false, 0)
		assert_eq(wPhobia, -1.0)


	func test_blocking_effect() -> void:
		var effect: StatusEffect = autofree(StatusEffect.new())
		effect.id = StatusEffectManager.StatusEffects.BLOCKING

		var fullHp := effect.get_setup_potential(user, target, true, 0)
		assert_eq(fullHp, 0.5)
		fullHp = effect.get_setup_potential(user, target, false, 0)
		assert_eq(fullHp, -0.5)

		target.current_hp = int(target.hp / 2.0)

		var halfHp := effect.get_setup_potential(user, target, true, 0)
		assert_eq(halfHp, 1.0)
		halfHp = effect.get_setup_potential(user, target, false, 0)
		assert_eq(halfHp, -1.0)


	func test_poison_effect() -> void:
		var effect: StatusEffect = autofree(StatusEffect.new())
		effect.id = StatusEffectManager.StatusEffects.POISON

		var fullHp := effect.get_setup_potential(user, target, false, 0)
		assert_eq(fullHp, 1.0)
		fullHp = effect.get_setup_potential(user, target, true, 0)
		assert_eq(fullHp, -1.0)

		target.current_hp = int(target.hp / 2.0)
		var halfHp := effect.get_setup_potential(user, target, false, 0)
		assert_eq(halfHp, 0.5)
		halfHp = effect.get_setup_potential(user, target, true, 0)
		assert_eq(halfHp, -0.5)
		
	
	func test_healing_effect() -> void:
		var effect: StatusEffect = autofree(StatusEffect.new())
		effect.id = StatusEffectManager.StatusEffects.HEALING

		var fullHp := effect.get_setup_potential(user, target, true, 0)
		assert_eq(fullHp, 0.5)
		fullHp = effect.get_setup_potential(user, target, false, 0)
		assert_eq(fullHp, -0.5)

		target.current_hp = int(target.hp / 2.0)
		var halfHp := effect.get_setup_potential(user, target, true, 0)
		assert_eq(halfHp, 1.0)
		halfHp = effect.get_setup_potential(user, target, false, 0)
		assert_eq(halfHp, -1.0)
