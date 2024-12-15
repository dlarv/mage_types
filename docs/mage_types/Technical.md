# Technology Used
Game Engine: Godot
Project will be made in Godot. ~~C# will be used to create foundational systems. Things like UI and signal handling can be handed in GDScript, if the implementation would be simpler. Nodes written in GDScript can interface with C# nodes, but not vice versa. C# systems should be self contained.~~
- Project is now written completely in gdscript, as I ran into this issue: [https://github.com/godotengine/godot/issues/78513](https://github.com/godotengine/godot/issues/78513).
- If any systems need to be optimized, I will rewrite them in c++.

Using the “Dialogue Nodes” by Nagi addon for Godot. This should make designing the dialog/story system easier.

Art: TBD, probably Blender.
[Clay Doh](https://blendermarket.com/products/claydoh) by DoubleGum is a procedural shader pack that gives objects a clay-like material. It cost $30 and contains 13 different materials, which I personally think is a great deal. It has a royalty-free license as well.

Audio: TBD.
# Specifications
## Battle System (BATT)
### Overview
_Battle_: Node:
- Reqs:
	- Entry point for starting a battle.
	- Init BattleGUI.
	- Handle end of battle logic and return control directly to caller.
- Methods:
	- Start(BattleActor[], BattleItem[], BattleActor[], OpponentController)
- Signals:
	- BattleEnded(Was Player Defeated: bool)
	
_BattleOverworld_: Node3D:
- Reqs:
	- Pause Overworld while battle is running.
	- Resume Overworld once battle is finished.
	- Init Battle.
- Methods:
	- OnBattleStarted(BattleActor[], BattleItem[], EnemyActor)

_EnemyActor_: Area3D:
- Reqs:
	- Attached to a character who can participate in battle.
- Fields:
	- Ai: OpponentController
	- Team: BattleActor[]
	- Fight On Collision: bool
	
_BattleGUI_:
- Reqs:
	- Get action selections from user.
	- Send list of actions to Battle.
	- Receive animations from Battle and play them.
	- Receive messages from Battle and display them.
	- Update BattleActor hp bars/etc.
### BattleGUI
*I don't want to redo the work I've done here (at least not yet). This will just be a rehash of what I've already created.*
### Battle Loop
1. Setup:
	1. Ensure ElementManager is up to date.
	2. Connect all `BattleActor.was_just_defeated` signals.
		1. When an ally is defeated, increment `_defeated_allies` counter.
		2. Likewise for enemies.
	3. Call `OpponentController.setup(enemies)` to initialize ai.
	4. Connect `OpponentController._on_battle_ended()` to `Battle.battle_ended` signal.
	5. Initialize GUI.
2. Player selects their actions:
	1. Select Item/Attack.
	2. View info about Item/Attack/Ally/Enemy/Status Effect.
	3. Go to previous actor and reselect action.
	4. Go to next actor.
	5. End turn.
3. Action resolution (Prep):
	1. Battle receives `BattleGUI.actions_selected` signal.
	2. Disable Player's controls.
	3. Check if player tried to flee.
	4. Get actions from `OpponentController.get_actions(...)`.
	5. Combine player and opponent actions into 1 array and sort by priority, speed, then predetermined tie breaker.
		1. Tie breaker is a coin toss performed every turn before actions are sorted. Determining the tie breaker inside of the sort function will throw a non-fatal error.
4. Action resolution 2 (Execution):
	1. Iterate over actions.
		1. If an action is null, this means that character was defeated or flinched. Skip...
	2. Play animation:
		1. Animations require a start and end position.
			1. Start = user's sprite's position.
			2. End depends on target's position.
	3. Display message to player, wait for them to clear it.
	4. Check if battle should end (due to damage).
	5. Transmutations:
		1. Calculate target(s) transmutations.
			1. If target has stasis condition, return early.
			2. Calculate `target.element1` + `attack.element` transmutation.
				1. Change element, if applicable.
				2. Apply side effects, if applicable.
			3. Calculate `target.element2` + `attack.element` transmutation.
				1. Change element, if applicable.
				2. Apply side effects, if applicable.
			4. If target has dissonance condition, return early.
			5. Calculate `target.element1` + `target.element2` transmutation. 
				1. Change element, if applicable.
				2. Apply side effects, if applicable.
		2. Check if battle should end (due to phobia damage).
		3. Calculate user transmutations, unless they were included in the targets (repeat step 1).
		4. Check if battle should end (due to phobia damage).
	6. Call `BattleActor.resolve_end_of_turn()` on user.
		1. Resolves poison and healing heath$\Delta$.
		2. Calculate any end of turn affinity gain.
		3. Remove expired status conditions.
		4. Display message containing all the above, wait for player to clear.
	7. Pause for small amount of time before continuing to next iteration.
5. Iterate over all Actors and test if they should revert back to their bias.
6. Re-enable player controls and throw control back to them.
### Attack Design
See [[Design#Adding an Attack|here]] for instructions on how to create a new attack.

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
- Cost: int
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

#### List of Attack Effects (v0.1.0)
| Name                  | Description                                                                                                                                                   | Strength        | Duration | Other Fields                               |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | -------- | ------------------------------------------ |
| Damage                |                                                                                                                                                               | Power of attack |          |                                            |
| Elemental Effect*<br> | Abstract class for effects that involve 1+ elements.                                                                                                          |                 |          | Element: ElementalType                     |
| Instant Health Change | Similar to Damage. Modifies the target's health instantly, as opposed to ovet time.                                                                           | %health         |          | Allow Overflow: bool                       |
| Stat Change           |                                                                                                                                                               | %change         |          | Stack: int                                 |
| Status Heal           | Heals status effect from target, if applicable.                                                                                                               |                 |          | Effect: StatusEffect<br>                   |
| Transmutate           | Changes the target's type to `Element`, if they are not already.<br><br>If `id` == 0, change the target's primary type.<br>Otherwise, change their secondary. |                 |          | Element: ElementalType<br><br>Id: { 0, 1 } |
\*ElementalEffect: Due to a workaround that had to be implemented to get Phobias to work w/o creating 8 unique resources, it may be better to move `Element: ElementalType` up into the `Effect` class instead.

Below is an explanation of this workaround and why it was needed.
> 1. A unique instance of `Effect` is created per `Attack`.
> 2. One instance of the Phobia `AttackEffect` is  created, where `Element=Blank`, `Duration=3`, and `Description="..."`
> 3. To create an attack with a Phobia effect, a new `Effect` is created and given a reference to the previous instance.
>
> The issue arises when trying to set the value of the `Element` field. Setting `Element` directly will change this value for ALL attacks. So the obvious next step is to make this instance of Phobia unique. However, this creates the potential problem in the future, where if the value of `Duration`/etc is changed, it will have to be changed in every attack that has a Phobia effect.
>
> Instead, `Element` can be made a field inside of `Effect`, which will be ignored in most non-`ElementalEffect`s (set equal to Blank). Since Effect is designed to be a unique instance regardless, this won't require any extra design changes. However, this will incur some cost to memory.
#### Cost
As discussed in [[Background#Affinity Info]], there will be 3 types of affinity (R, G, B). There's a few ways this cost could be implemented:
- An attack's cost is not tied to its type (so a Blue attack can cost Green affinity).
- An attack's cost is based on its composite colors (so a Yellow attack costs 1+ Green and 1+ Red).
- An attack's cost is determined by its lore relationships.
	- Red, Orange, Yellow, Magenta cost Red affinity.
	- Green costs Green affinity.
	- Blue, Purple, Cyan cost Blue affinity.
I lean towards the third, but I think it makes the 2nd most sense.
#### Damage
The current damage formula is as follows: $$Damage = Power \times {Attack \over Defense} \times Affinity \times Rand$$
Where:
Rand = \[0.8, 1.0]
Affinity = \[0, 1]
**This is subject to change.**
### Battle Actor
Every character that can participate in battle must have a BattleActor. 

_BattleActor_: Resource:
- Name: string
- Hp: int
- Current Hp: int
- Sprite: Sprite
- State Managers:
	- Statuses: StatusEffectManager
	- Affinity Manager: AffinityManager
	- Stat Manager: StatManager
- Elemental Data:
	- Element1: ElementalType
	- Element2: ElementalType
	- Elemental Bias: ElementalType
	- Bias Reversion Threshold: float
- Attacks: BattleAction\[]
- Already Defeated: bool

_StatusEffectManager_: Node:
- Poison: float
- Healing: float
- Blocking: StatusEffect
- Phobias: Dict\<ElementalType, StatusEffect>
- Statuses: Dict\<string, StatusEffect>

_StatManager_: Resource:
- Base \<Stat>: float
- \<Stat> mod: float
- \<Stat>: float

_AffinityManager_: Resource:
- Initial Red Affinity: int
- Initial Green Affinity: int
- Initial Blue Affinity: int
- Element1 Counter: int
- Element2 Counter: int
### Attack Builder Addon
I want to make an interface to make creating new attacks, which can be exposed as an addon, as well as in-game (in a sandbox mode).

The UI would have to allow the user to select the following fields: 
- Battle Action
	- Name: string
	- \*Animation: PackedScene
	- Element: ElementalType
	- Priority: int
	- Range: { Melee, Ranged, Status }
	- Target: { Self, Ally, Allies, Enemy, Enemies }
	- Details: string
- Attack
	- Cost: int
	- Effects: _Effect_\[]
		- Target: { User, Target }
		- Chance: percentage
		- \*AttackEffect: _AttackEffect_
\*These will have to give the user limited access to the filesystem.

In addon mode, the user should be given the option to save their new move to the filesystem.
In sandbox mode, the user should be given a spellscroll containing their new move.
### Opponent Controllers
There are 2 types of OpponentControllers, scripted and general purpose. Currently, only the first is implemented.

In v0.1.0, the former type of controller was difficult, as it wasn't clear what kind of decisions would be the most 'strategic.' Now, with the addition of resistances, this is slightly easier.

**AI Settings**:
- Aggression:
	- High aggression: the opponent will use whatever attack does the most damage.
	- Low aggression: the opponent will use setup moves more often.
- Intelligence:  How likely is the opponent to select the optimal move.
- Transmutation: How much the opponent weights causing transmutations in the player.
	- This will likely not care about the exact transmutation, just that one happens.

**AI Decision Process**:
```c#
float maxVal = 0;
BattleActor maxActor = targets[0]; 
BattleAction maxAction = actions[0];

foreach(BattleAction action in actions) {
	float currDmg = 0;
	int currTransCount = 0;
	float currStatusCount = 0;

	// Check status potential.
	currStatusCount = action.GetStatusPotential();

	foreach(BattleActor actor in targets) {
		// Count number of transmutations.
		ElementalType e1 = ElementManager.GetMatchup(actor.element1, action.element);
		ElementalType e2 = ElementManager.GetMatchup(actor.element2, action.element);
		ElementalType e3 = ElementManager.GetMatchup(e1, e1);
		currTrans +=  e1 != null ? 1 : 0
						+ e2 != null ? 1 : 0
						+ e3 != null ? 1 : 0;

	
		// Calculate damage.
		currDmg = actor.GetDamageNoApply(action);
		// Check potential phobia damage.
		currDmg += actor.HasPhobia(e1);
		currDmg += actor.HasPhobia(e2);
		currDmg += actor.HasPhobia(e3);

		// Calculate value.
		float val = currDmg * this.aggressionBias 
					+ currTransCount * this.transmutationBias
					+ currStatusCount * this.setupBias
					// Confounding factor.
					+ Random() * this.intelligence;

		// Update maximum value.
		if(val > maxVal) {
			maxVal = val;
			maxActor = actor;
			maxAction = action;
		}
	}
}
```
## Overworld (OVER)
## Story (STRY)
## Character Management and Inventory (CHAR)
## Setting and Accessibility (ACCS)
## Polish and Aesthetics (POLI)