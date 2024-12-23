#discussion 
# Attack Design
_BattleAction_: Resource:
- Name: string
- Animation: PackedScene
- Element: ElementalType
- Priority: int
- Range: { Melee, Ranged, Status }
- Target: { Self, Ally, Allies, Enemy, Enemies }
- Details: string

>[!note] Battle Items
>Battle Items also inherit from BattleAction. Discussion of them can be found here: [[item_management]].

_Attack_: BattleAction:
- Cost
- Effects: _Effect_\[]

Sealed _Effect_: Resource:
- Target: { User, Target }
- Chance: percentage
- AttackEffect: _AttackEffect_
**Acts as a wrapper, encapsulating a specific subclass of AttackEffect.**

Abstract _AttackEffect_: Resource:
- Name: string
- Chance: percentage
- Strength: percentage || float
- Message: string

 _StatusEffect_: AttackEffect:
- Duration: int
- Icon: PackedScene
- Description: string

>[!note] BattleAction.Target vs Effect.Target
> The inclusion of this field in both these classes may seem redundant (and it likely is). 
> The former is used by the UI and Battle classes to determine things like animation placement, while the latter is used to determine which actor(s) to apply the effect to.

# List of Attack Effects (v0.1.0)
| Name                  | Description                                                                                                                                                   | Strength             | Duration | Other Fields                                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| Damage                |                                                                                                                                                               | Power of attack      |          |                                                                                                              |
| Elemental Effect*<br> | Abstract class for effects that involve 1+ elements.                                                                                                          |                      |          | Element: `ElementalType`                                                                                     |
| Instant Health Change | Similar to Damage. Modifies the target's health instantly, as opposed to ovet time.                                                                           | %health              |          | Allow Overflow: `bool`                                                                                       |
| Stat Change           |                                                                                                                                                               | %change              |          | Stack: `int`                                                                                                 |
| Status Heal           | Heals status effect from target, if applicable.                                                                                                               |                      |          | Effect: `StatusEffect`<br>                                                                                   |
| Transmutate<br>       | Changes the target's type to `Element`, if they are not already.<br><br>If `id` == 0, change the target's primary type.<br>Otherwise, change their secondary. |                      |          | Element: `ElementalType`<br><br>Id: { 0, 1 }                                                                 |
| Blocking              | Prevents the next instance of damage.                                                                                                                         | %damage blocked.     |          |                                                                                                              |
| Dazed                 | i.e. paralysis.                                                                                                                                               | %chance of turn skip |          |                                                                                                              |
| Dissonance            | Prevents primary + secondary transmutations.                                                                                                                  |                      |          |                                                                                                              |
| Stasis                | Prevents Attack based transmutations.                                                                                                                         |                      |          |                                                                                                              |
| Phobia                | Deals damage upon transmutation into a specific element.                                                                                                      | %damage              |          | Element: `ElementalType`                                                                                     |
| Philia                | Deals damage upon transmutation into a specific element.                                                                                                      | %healed              |          | Element: `ElementalType`                                                                                     |
| Poison                | Damage over time.                                                                                                                                             | %health              |          |                                                                                                              |
| Healing               | Healing over time.                                                                                                                                            | %health              |          | <br>                                                                                                         |
| Random Phobia         | Inflicts a number of randomly selected phobias.                                                                                                               |                      |          | Min: `int`<br>Max: `int`                                                                                     |
| Strike                | Does extra damage based on either the user's or target's type. Otherwise, does decreased damage.                                                              | Power                |          | Element: `ElementalType`<br>Type: { STAB, TARGETED }<br>Positive Factor: `float`<br>Negative Factor: `float` |
| Draining Damage       | Does damage to the target and heals the user.                                                                                                                 | Power                |          | Heal Percent: `float`<br>Allow Overflow: `bool`                                                              |
| Generate Affinity     | Gives the target affinity.                                                                                                                                    | # Affinity granted   |          | Element: `ElementalType`                                                                                     |
\*ElementalEffect: Due to a workaround that had to be implemented to get Phobias to work w/o creating 8 unique resources, it may be better to move `Element: ElementalType` up into the `Effect` class instead.

# Elemental Effect Workaround Explained
Below is an explanation of this workaround and why it was needed.
> 1. A unique instance of `Effect` is created per `Attack`.
> 2. One instance of the Phobia `AttackEffect` is  created, where `Element=Blank`, `Duration=3`, and `Description="..."`
> 3. To create an attack with a Phobia effect, a new `Effect` is created and given a reference to the previous instance.
>
> The issue arises when trying to set the value of the `Element` field. Setting `Element` directly will change this value for ALL attacks. So the obvious next step is to make this instance of Phobia unique. However, this creates the potential problem in the future, where if the value of `Duration`/etc is changed, it will have to be changed in every attack that has a Phobia effect.
>
> Instead, `Element` can be made a field inside of `Effect`, which will be ignored in most non-`ElementalEffect`s (set equal to Blank). Since Effect is designed to be a unique instance regardless, this won't require any extra design changes. However, this will incur some cost to memory.
