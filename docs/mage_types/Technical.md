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
- Effects: _BaseEffect_\[]

_BaseEffect_: Resource:
- Target: { User, Target }
- Chance: percentage
- AttackEffect: _AttackEffect_
- Element: ElementalType
**Acts as a wrapper, encapsulating a specific subclass of AttackEffect.**

_Effect_: BaseEffect:

_ConditionalEffect_: BaseEffect
- Condition: _Condition_
- Success Effect: _Effect_ (**not** _BaseEffect_)
- Failure Effect: _Effect_

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
![[attack_effects#List of Attack Effects (v0.1.0)]]
#### Cost
As discussed in [[Background#Affinity Info]], there will be 3 types of affinity (R, G, B). There's a few ways this cost could be implemented:
- An attack's cost is not tied to its type (so a Blue attack can cost Green affinity).
- An attack's cost is based on its composite colors (so a Yellow attack costs 1+ Green and 1+ Red).
- An attack's cost is determined by its lore relationships.
	- Red, Orange, Yellow, Magenta cost Red affinity.
	- Green costs Green affinity.
	- Blue, Purple, Cyan cost Blue affinity.
I lean towards the third, but I think it makes the 2nd most sense.

> After some consideration, I think I will have two affinity pools: offensive and defensive. This way, there is conceptual overlap with the side effect system.

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

>[!important] Equipment Changes (v0.3.4)
>Added `_func_overrides`. This allows ModEquipment to replace methods inside of BattleActor with new ones. 
>For instance, the item Willpower acts similar to the focus band from Pokemon, leaving the holder with 1hp the first time they would have been knocked out. This is done by replacing the BattleActor.apply_damage method with one that does the relevant checks.
>
>The following methods can be overridden:
>- apply_damage()
>- add_status_effect()
>- add_affinity()
>- lose_affinity()
>- try_revert_to_bias()
>- resolve_end_of_turn()
### Attack Builder Addon
[[attack_builder|GUI Layout]]
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
### Actor System
- `BattleActor`: Each individual participating in a battle must have its own `BattleActor`.
- `EnemyActor`: An enemy from the overworld who can participate in the battle.
- `StoryActor`: All character's who can react to the story and/or have dialog must have a `StoryActor`.
- `VendorActor`: A character who gives the player access to a shop.

>[!note] BattleActors vs EnemyActors
>To draw an analogy:
>A `BattleActor` is like an individual Pokemon, while an `EnemyActor` is like a trainer.
>So in this example an Enemy will have 1 `EnemyActor`, but ~6 `BattleActor`s.
#### Enemies
There are two types of enemies the player will interact with:
- [[#Wild Enemies]], which attack on collision.
- Aggressive Story Actors, which have dialog pre-fight which can be used to pivot into the battle. 

In order to participate in battles, a character must have an `EnemyActor`. This `EnemyActor`, in turn, has 1+ `BattleActor`s.

Wild Enemies:
- ~~Player monitors for collisions with EnemyActors.~~
- Enemy is removed from scene.
- Player emits `battle_started` signal.

A. Story Actor:
- ~~Player monitors for collisions with StoryActors.~~
- Player clicks thru dialog.
- At end of dialog tree/branch, DialogNode emits `battle_started` signal.
- Player emits `battle_started` signal.

>[!question] 
>In v0.1.0, there is a separate class for AggressiveEnemyActors. I'd prefer this not to be the case.
>Currently, the `EnemyActor` has a `fight_on_collision` toggle. I would prefer to have the `StoryActor`'s collision take precedence over `EnemyActor`.
#### Story Actors
Story Actors need to have to ability:
- \*Display dialog when talked to by the player.
- \*Change their dialog in response to story events.
- Have dialog that involves multiple characters.
- A character gives/takes an item from the player.
	- For multiple items, use `VendorActor`.
- Character is able to remember simple info given to them by a player.
	- A nickname, answer to a question.
- Move camera while a character talks.
- \*Pivot into combat.
\*Aspects that belong in the MVP.

#### Dialog Pivots
A pivot represents what the game should do (re: pivot to) once the dialog has ended. Whichever class called `DialogueBox.start(…)` should await for `DialogueBox.dialog_signal`, the return value of which represents the pivot.

| Name            | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| dialogue_ended* | Dialog simply ends without pivoting to anything.             |
| pivot_declined  | Emitted if player has option to start pivot, but declines.   |
| battle_started  | Signals that battle should be initiated.                     |
| menu_opened     | Emitted if menu should be opened, e.g. a shop keeper/vendor. |
\*The Dialogue Node addon was modified to emit this signal alongside `DialogueBox.dialogue_ended` to facilitate this. So the node now emits both a `dialogue_ended` signal as well as `dialogue_signal("dialogue_ended")`.
#### Creating an NPC
Each type of actor will be added as a child to NPC node.

| Enemy | Vendor | Story | Behavior                                                                                           |
| ----- | ------ | ----- | -------------------------------------------------------------------------------------------------- |
|       |        |       | The NPC will do nothing.                                                                           |
| x     |        |       | NPC immediately starts a battle upon collision.                                                    |
| x     |        | x     | Display interact prompt upon collision.<br>Optionally pivot into battle depending on player input. |
| x     | x      |       | *Not really intended*.                                                                             |
|       | x      |       | Display interact prompt upon collision.<br>If player interacts, immediately open shop menu.        |
|       | x      | x     | NPC has 1+ dialog trees. <br>At least 1 contains the ability to open shop menu.                    |
|       |        | x     | NPC has 1+ dialog trees. Start active one when interacted with.                                    |
The `StoryActor` will contain dialog data.
The `VendorActor` will contain shop data.
The `EnemyActor` will contain a list of `BattleActor`s and an `OpponentController`.

Actors will be managed by the `NPC` class. 
_NPC_: Node3D:
- Reqs:
	- Detect collisions with player.
	- Manage Actor precedence. See table above.
	- Set collider size and shape in inspector.
	- Show 'interact' prompt, if applicable.
[[Design#Characters|See here for instructions on how to add new characters to scene]].
### Wild Enemies
#### Spawning
- An area monsters can spawn in.
- A list of monsters that can spawn.
	- A list of attacks each monster can know.
	- How many attacks should each monster know.
	- Loot tables for each monster.
	- How many BattleActors per EnemyActor.
- How likely each monster can spawn.
- A default opponent controller.
- How often to spawn a new enemy.
- Maximum number of entities to spawn.
#### Behavior
### Level Design
I prefer working with Blender's 3D editor over Godot's, so I'd like to do as much as possible in the former.
#### Chunking
- World
	- Regions
		- Rooms
The `Regions` are the same as in the lore.
The world will be loaded in one `Room` at a time.
#### Demo Area
[[demo]]
#### Puzzle Blocks
> Puzzle blocks, MagiClay, and physics objects can all overlap.

Puzzle blocks are logical elements that are used to build puzzles (if you can believe such a thing). Most PuzzleBlocks should be effected by at least Catalyst and Stasis.

```
PuzzleBlock extends MagiClay

signal on(PuzzleBlock)
signal off(PuzzleBlock)

public bool is_on

public void start(Variant)
public void stop(Variant)

private void _try_emit_on()
private void _try_emit_off()
```

#todo 
- MagiClay.\_flicker_collider()
- Laser.rand_val
- puzzle chunks and reset blocks
- Relays, delays, and flipflops.
##### Lasers
![[laser_system]]

### Overworld Spells
1. Allow user to select spell.
2. Apply effects of spell to overworld.
	1. Particle effect/animation.
	2. Apply effect to entity.
	3. Apply effect to MagiClay.
3. Remove spell effects from overworld after expiration.

Entities:
- MagiClay (2.3, 3)
- SpellManager (1)
	- Parent to all OverworldSpell objects.
	- Child of Player.
	- Interfaces with inventory to determine which spells are disabled.
	- Selects which spell is currently active.
- OverworldSpell (2.1, 2.2)
	- Handles UI and activation.
- Projectile
	- Exist in 3D physics space.
	- Collide with 1+ objects.
#### Overworld Spell: Stasis
1. Project a ray from the player to ground in front of them.
2. Rotate ray around player until MagiClay or PhysicsObject is found, or ray completes 360deg.
3. If projectile collides with MagiClay, prevent effects until expiration.
4. Elif projectile collides with PhysicsObject, prevent physics until expiration.
>[!important] 
> Stasis now works like a toggle. I.e. it doesn't expire after a certain amount of time, instead turning off if the player hits the object with a second stasis spell.
>
> The player can also only have 3 objects under stasis at a time. If they select a fourth, the first object they selected is released from stasis.
#### Overworld Spell: Destroy
1. Get element of MagiClay under player's feet.
2. Shoot projectile in direction the player is facing.
3. If projectile collides with a *breakable* MagiClay *obstacle*, get resistance matchup:
	1. If projectile is super-effective, destroy obstacle and projectile.
	2. Otherwise, projectile bounces (or is destroyed).
#### Overworld Spell: Vines
1. Project a ray from the player to ground in front of them.
2. Rotate ray around player until *blooming* MagiClay is found or ray completes 360deg.
3. If MagiClay is found, begin growing sequence.
#### Overworld Spell: Catalyst
1. Get element of MagiClay under player's feet.
2. Shoot projectile in direction the player is facing.
3. If projectile collides with a *transmutable* MagiClay *obstacle*, get resistance matchup:
	1. If transmutation exists, transmute obstacle.
	2. Otherwise, projectile bounces (or is destroyed).
#### Overworld Spell: Tunnel
1. When game is compiled, all MagiClay without a *tunnel override* finds its closest neighbor.
2. Project a ray from the player to ground in front of them.
3. If ray collides with MagiClay, create a tunnel instance.
4. When player collides with tunnel instance, teleport them to *other side*.
#### Summary
_MagiClay_:
- Subtypes:
	- Terrain: Part of the ground/walls.
	- Obstacle
- Fields:
	- Is Blooming: `bool`
	- Is Breakable: `bool`
	- Is Transmutable: `bool`
	- Is Active: `bool`
	- Tunnel Override: *MagiClay*
- Methods:
	- PerformAction(`ElementalType`, `func`)
_SpellManager_: `Node3D`:
- Reqs:
	~~- Enable spells based on game events.
		- Interface with Inventory.~~
	- Get input from user to activate spell.
- Methods:
	- ActivateSpell(`OverworldSpell`, `bool`)
_OverworldSpell_: `Interface` | `Node3D`:
- Reqs:
	- When active, listen for player input.
- Methods:
	- SetActive(`bool`)
_Projectile_: `Node3D`:
- Reqs:
	- Travel in straight line upon creation.
	- When collision, test for MagiClay. 
		- If test passes, perform action on MagiClay.
		- Otherwise, bounce.
			- Once `max_bounce` threshold is reached, destroy self.
- Fields:
	- MaxBounces: `int`
	- CollisionTest: `func(Node3D) -> bool`
	- ActionToPerform: func(`Node3D`, `ElementalType`)
- Methods:
	- Constructor(`func`, `func`, `ElementalType`)

The following system will need to interface with the Overworld Spells, esp which ones are currently enabled:
- Inventory Screen
	- Allow player to select which spells they want active.
- OverworldSpellManager
	- Controls which spells are currently active.
- Overworld UI
	- Show which 2 spells the player has active.

**When a spell is enabled(disabled)**:
1. When player unlocks a new overworld spell, call `Inventory.enable_overworld_spell`.
2. `Inventory` emits `overworld_spell_enabled(OverworldSpell.Spells, bool)` signal.
3. `OverworldSpellMenu` listens to aforementioned signal and shows(hides) appropriate spell.

**When a spell is selected**:
1. Player selects primary/secondary spell from `OverworldSpellMenu` (inside of `PlayerMenu`).
2. `OverworldSpellMenu` sets values inside of `Inventory` singleton using `Inventory.select_overworld_spell(OverworldSpell.Spells, bool)`.
3. `Inventory` emits `overworld_spell_selected(OverworldSpell.Spells, bool)` signal.
4. `OverworldSpellManager` listens to aforementioned signal.
5. Player gives use-spell input.
6. `OverworldSpell` triggers its effect.

>[!important] 
> Players collision layer is 1.
> Projectile collision layer is 2.
> MagiClay collision layer is 3.
> Laser collision layer is 4.
>- Things that block lasers are on layer 5.
> - Layer 6 is for things that only affect the player.
#### MagiClay
MagiClay is used for parts of the environment that must interact with OverworldSpells and/or have elemental types.

It must have the ability to support the following effects:
- Stasis: Freeze physics and other spell effects.
- Catalyst: Causes a transmutation to occur.
- Destroy: Removes object.
- Vines: 
- Tunnel:

Not every instance of MagiClay has to support every effect. Which effects a particular instance supports is controlled using exported boolean values.

>[!important]
>For the demo, only Stasis, Catalyst, and Destroy will be available.

### Grabbable
Adding this component as a child to a MagiClay/PuzzleBlock/OverworldItem will allow the player to grab/pick it up.

Its primary purpose is to display a 'pickup' prompt when the player is near. *its parent must determine what happens when the player presses this button*. The parent can accomplish this by listening to the `Grabbable.grabbed(Node3D, Player)` signal.
## Story (STRY)
#todo
## Character Management and Inventory (CHAR)
The PlayerMenu has 2 major tabs: `Characters` and `Inventory`.
The Characters tab is broken into `Info`, `Stats`, and `Spells`.
The Inventory tab is broken into `Items` and `Spells`.
### Character Menu
Each character controlled by the player has their own tab. Each of these tabs, in turn, have 6 subtabs: Info, Stats, Spells, Equipment, Abilities, Misc. Each of these tabs are split in half vertically. The left column has ui elements, while the right displays info about whatever the player has currently selected.
#### The Info Tab
This tab displays general information about the character, including:
- Their name.
- The primary and secondary types.
- Their alignment (bias).
- Their exp/level.
#### The Stats Tab
All players have 8 stats: hp, melee/ranged attack, melee/ranged defense, speed, evasion. The player character has 1 more: stamina.
The stat screen has 2 boolean switches: editable and debug mode.
- If editable is on, player can increment/decrement stats by 1.
- If debug mode is on, player can enter any arbitrary number.

How should character’s stats grow over time?
- Stat points: player earns points that they can invest into whatever stats they want.
- Automatically: as the player levels up.
#### The Spells Tab
This tab is the only way in game that the player can interact with their moveset, which means all restrictions should be handled here.
- View info about spells.
- Learn new spell.
- Replace spell.
- Forget spell.
### Inventory
- ~~Quickly load items from filesystem.~~
- Easily add items inside of editor (wrapping them in ItemSlot).
- Dynamically add items during runtime (e.g. if player creates an item using the debugger).
- Provide access to inventory from battle.

There are 4 types of items:
- Regular Items
- Spell Scrolls
- Equipment
- Key Item

Regular items can optionally have a `BattleItem` component, which allows them to be used in battle.
Each type of item will be kept in its own array. An `item.id` is relative to its array (i.e. there can be up to 4 items with `id=0`). An item's id will be the same as its index. *This is used when searching for items.*

There will be several helper vars exposed to the editor:
- `add_item`: Dragging items here will add them to the correct array and wrap them in an `ItemSlot`.
- `add_item_dir`: Like `add_item`, except it will perform a dfs on a directory, loading all items it finds. *It will not check if the item has already been added to the list!*
- `recalc_ids_*`: Each item array will have its own `bool` var. When pressed, it will recalculate all item ids. This is useful when used to manually sort the order items will appear, after loading them in using the other helper vars.

## Setting and Accessibility (ACCS)
## Polish and Aesthetics (POLI)
### MenuManager
- Settings
- Save/Load
- Transmutation reference
- Player character management
- Player inventory management
- Item selector
	- Equipment
	- Regular
	- Attack
- Vendor/merchant

Player selects new spell or equipment from inside Character Screen:
1. Player presses `Replace` button.
2. `MenuManager` opens limited inventory screen.
3. Game awaits for player to select an item or cancel.
4. Modify `BattleActor`.
5. `CharacterScreen` (which listens for changes to `BattleActor`) updates GUI.

Player selects new spell or equipment from inside Inventory:
1. Player selects item from `InventoryMenu`.
2. Player presses `Select` button.
3. Player selects which character to apply to.
4. Player confirms which 