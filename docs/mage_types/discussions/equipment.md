Equipment, in its current incarnation, act like held items from Pokemon. 

>[!warning]
>The main battle loop is mostly synchronous. But the way equipment works forces it to be async. 


# Adders or Modifiers
There will be  two types of equipment: Adders and Modifiers.

Adders have a `Trigger` and `Bonus`. The Trigger listens to specific events, activating the Bonus when its conditions are met. Every equipment has its own message queue, which must be flushed by its BattleActor.

Modifiers alter something about the BattleActor when equipped.
# Bonuses
Bonuses should only effect the character holding the item.

- Apply stat buffs.
- Modify base stats.
- Apply status condition(s).
- Block status condition(s).
- Reduce/increase damage.
# Adders
## Trigger Conditions
A BattleActor has the following signals, each of which can easily facilitate a EquipmentTrigger:
- On actor defeated.
- On status effect added/removed.
	- This could be split into stat changes and normal status conditions.
- On damage applied.
- On element changed.

It could be cool to support the following conditions as well:
- On battle started.
- On opponent defeated.
## Bonuses
- Apply stat buffs.
- Apply status condition.
- Instant health change.
# Modifiers
- Modify base stats.
- Change side effect dynamics?
- Boost specific attacks.

Using `BattleActor._func_overrides`, the following methods can be replaced with new ones:
 - apply_damage()
 - add_status_effect()
 - add_affinity()
 - lose_affinity()
 - try_revert_to_bias()
 - resolve_end_of_turn()
Any items that modify these will likely need their own class (inheriting from `ModEquipmentEffect`).