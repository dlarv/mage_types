# Misc Notes
- [ ] Revisit [[Story]], [[Background#The Factions]], and [[Background#Elemental System]]

>[!summary] Realignment
> I feel like I'm adding puzzles for the sake of adding them and furthermore I dislike the process. This isn't helped by the fact that this game isn't really meant to be a puzzle game. 
> 
> The parts I do enjoy are making are coming up with quirky little lore and worldbuilding ideas. I think this game will primarily be an exploration and narrative experience, with minor puzzle elements. With this in mind, it might be best to focus on fleshing out the hotel and caves areas of the map. 
- Portal Complex becomes a series of excavation sites.
	- I like the Orange chatlogs and murals.
- Western section of hotel expanded.
	- Lavender's logic puzzle.
- Hotel rooms added.
	- This can contain small challenges/puzzles/etc.
	- Ideas can be drawn from SCP-7819.
	- I want there to be a second floor.
# Objectives
- Refine design processes
	- 3 types of updates
		- Mechanic
		- Content
		- Aesthetic
- Practice making challenges
# Upcoming Versions
[[version_naming_scheme]]
## v0.6.x
Battle aesthetic update: [[more_dynamic_battles]]
- [ ] Battle messages
	- [ ] Message Feed should resemble twitch chat
		- [ ] Lines should be simple Strings
		- [ ] Make translucent
		- [ ] Focus current turn info
		- [x] Bind to hotkey
	- [x] Only show InfoDisplay when player is selecting attack or character
		- [x] Logging: Since logs are created by the InfoDisplay, removing this will require the logs to be created elsewhere
	- [x] Refactor InfoDisplay to remove blocking message logic
		- [x] Remove calls to blocking messages from Battle
	- [x] Give player ability to toggle battle message display
	- [x] Show list of all messages sent during battle
	- [x] Have unique display formatting attacks and transmutation and misc effects
	- [x] Implement defeat bubble 
- [ ] Controlling animation
	- [ ] Setting to control speed and turn off animations
	- [x] Move status pin animations into BattleAnimator to ensure animations happen at correct timings (block mostly)
- [ ] Communicate important information using animations and graphics
	- [ ] Attack name
	- [ ] Damage numbers: How much dmg did the attack deal?
	- [ ] Equipment activations
	- [ ] Side effects
	- [ ] Transmutations
		- [ ] Interesting effect to show transmutation happening
		- [ ] ~~Icon on combatant name plate showing their current composition
	- [x] Animate hp rising/falling after attack animation
	- [x] Status effects activating: poison, phobia, flinched, stasis
	- [x] User and targets
	- [x] Whether attack dealt a status condition/extra effects
	- [x] Effectiveness: e.g. {actor} was wreathed in bright Blue light
		- [x] Bugfix: Since intention and affinity is communicated using the same particle emitter, if the player skips thru the animations, the call to turn off the particle effect will be called late, shutting off the intention effect instead
- [x] Dead code
	- [x] Remove String returned value from `resolve_end_of_battle()` 
	- [x] Remove `get_and_flush_msgs()` from BattleActor and related equipment info
- [ ] Bugfix: Incorrect BattleSprite is highlighted when player is selecting an action
- [x] Experiment with layout
	- [x] Combatant badges
	- [x] Player control buttons
		- [x] Remove character button (player will click on battle sprite)
	- [x] Speed rankings
		- [x] Change name from "Turn Order" to "Speed Ranking"
- [x] Implement flinch condition properly
	- [x] Prevent player from selecting actions for flinched characters
	- [x] Create flinch pin
- [x] Fix bug where selecting status pins appends message instead of replacing
- [x] Make playtesting enemies easier
	- [x] Show levels in UI
	- [x] Set player's level in debug mode
	- [x] Create beastiary to contain all monster data
	- [x] Create scene to setup battle
	- [x] Customize player team using unique battle actor
		- [x] Stats
		- [x] Attacks
		- [x] Number of team members
	- [x] Select monster team (interface with beastiary)
- [x] Show combatant's levels on name card and in Characters menu
- [x] Refactor wild enemy spawners
	- [x] Give spawner enemy base templates 
	- [x] Set custom spawn% for each enemy
	- [x] Allow spawner to adjust stats/etc of instantiated enemies
	
***QOL changes that will likely not be implemented in this version.***
- [ ] Speed ranking/turn order accounts for priority
- [ ] Use buttons to skip battle animations
- [ ] Attack Animation refactor
	- [ ] Renamed class and references
	- [ ] Animation should be selected via enum
	- [ ] Animation should be integrated with BattleActor animations
- [ ] Improved player model
	- [ ] Modeled
		- [x] Body
		- [ ] Hair
		- [ ] Face
	- [x] Textured
		- [x] Compare NextPassTransparency with Swapping diffuse maps
			- Swapping diffuse maps looks far better than the next pass method
	- [x] Animation
		- [x] Walk
		- [x] Basic Idle
		- [x] Battle Stance
		- [x] Channel power
		- [x] Attack
		- [x] Getting hit
- [ ] Make controls less obtrusive
	- [x] Attack, Item, and Run buttons should be small and off to the side
	- [ ] InfoDisplay
		- [ ] Hovering should highlight which name card is theirs
		- [x] Player can click on a BattleActor model to display info about them
		- [x] Hovering over status pin should tell you what it is and how many turns remaining it has
			- [ ] Hovering status pin should outline that pin
## v0.7.x
West and Central Hotel content update. Add puzzles and combat challenges to hotel.
- [ ] Upper West Hotel challenges
	- [x] Add puzzle
	- [x] Reward for solving main puzzle
		- [x] Hammer (Equipment): Melee attacks have +30% chance to flinch
	- [ ] Reward for solving alt puzzle
		- [ ] Access to hidden area? Alcove with additional chest?
	- [x] Add enemy encounters
- [ ] Add Magenta kitchen and breakfast
- [ ] Motel
	- [ ] Hidden caves logic puzzle (Lavender puzzle)
	- [ ] Motel/Backroom guardian monster
	- [ ] Monster encounters
	- [ ] Priority spell hidden in motel
	- [ ] Lavender fight
	- [ ] Destroy++ spell added at end of Lavender puzzle
- [x] Puzzle block demos:
	- [x] Laser blocks demos
		- [x] DraggableMirror?
		- [x] RotatableMirror?
		- [x] DraggableEmitter?
		- [x] OneWayLens?
	- [x] Pressure plate demo
		- [x] Bug: Player activated pressure plate not working
	- [x] Delay demo
	- [x] Timer demo
	- [x] Relay demo
		- [x] Create indicator block, which differentiates between off/on/invalid_off
## v0.8.x
World aesthetic update.
- [ ] Player animations
	- [ ] Jump 
	- [ ] Dash
	- [ ] Idle animation to play when player stands still for awhile
- [ ] Beastiary describing monsters
- [ ] Add wall paper
- [ ] Clay shader cracks are inverted?
- [ ] Add local lighting
- [ ] Map menu improvements
	- [ ] Icon showing which room player is in (use Player.active_chunk)
	- [ ] Ability to write on map?
- [ ] Replace placeholder door blockers/etc with models and diagetic explanations.
	- [ ] Add colliders and "Wet floor signs" to block access to Purple and Pools
	- [ ] Add out-of-order elevator to final pillar in ziggurat room
	- [ ] On doors player cannot enter, add "Do not disturb" signage
- [ ] Create door models and animations
	- [ ] Delay/animation before returning control to player? This would be necessary if rotating player model to face away from door
- [ ] Opening chests should show player list of contents and allow them to individually select them
- [ ] Scrapbook containing hints and notes the player has found
	- Notes can be obtained by interacting with parts of the environment. Diagetically, they are written on some form of carbon-paper sticky notes, allowing the player to take more than one copy of the same note. 
	- [ ] Notes can be obtained from overworld
	- [ ] Notes can be reorganized
	- [ ] Notes can be deleted
	- [ ] Player can create notes and drawings on notebook pages
- [ ] Materials and textures
	- [ ] Revisit clay shader. GDShader version should ideally be indistinguishable from the blender one
	- [ ] Animated water
	- [ ] PrincipledBSDF should have a plasticky look
- [ ] Character designs
	- [ ] Blue-aligned
	- [ ] Denim
	- [ ] Player
	- [ ] Lavender
- [x] Rails demo
	- [ ] Give Rail puzzleblock a model
- [ ] Logic gate demos
	- [ ] Add models for empty puzzle blocks?
- [x] Doors should keep player's relative position when they go thru
>[!note] Snapshot
> The end result of this version should act as a thin vertical slice of the demo, giving playtesters a better idea of what the game will look/feel like.
## v0.9.x
North caves, East hotel, and Beach content update.
- [ ] Portal Complex ruins created
	- [ ] Create and add models for murals
	- [ ] Orange chatlog object created and placed
- [ ] Finish blocking out the beach
	- [ ] Add backtrack puzzle to beach 1
	- [ ] Remodel beach 2 to look more organic
	- [ ] Add beach 3
- [ ] Lock and key system
- [ ] Stasis and Destroy spells added to map
	- [ ] Backtrack obstacles
	- [ ] Puzzles to obtain
## v0.?.x
Dual combat system. Some enemies can attack the player in the overworld. Some enemies will have steps the player must complete before the actual battle can start.
- [ ] Player hp stat should be accessible outside of battle
	- [ ] Hp bar in overworld
	- [ ] Wild enemies and obstacles should be able to damage player
- [ ] Wild enemies should have varying behaviors
	- [ ] Running away
	- [ ] Fighting
	- [ ] Ambushing
- [ ] Allow player and enemies to be staggered
	- [ ] Being staggered right before a battle starts should inflict flinching on turn 1
	- [ ] Player/enemy cannot move for a duration of time
- [ ] Determine mechanic that prevents player from starting battles with certain enemies before different requirements are fulfilled
- [ ] Add final boss to ~~stasis dungeon~~
## v0.?.x
Elemental system refactor
- [ ] Use proper enum instead of `@export_enum`
- [ ] Associate symbols with each element to help with differentiation
- [ ] Adjust `ElementalType.main_color` values
## v0.10.x
Demo candidate. Misc todos that must be completed before uploading to Steam.
- [ ] Accessibility
	- [ ] Colorblind support
	- [ ] Input remapping
	- [ ] Audio/video controls
- [ ] Achievements
- [ ] Start screen
- [ ] Audio
- [ ] Create steam page assets
- [ ] Refactor AttackEffect input fields to use Godot::Expression?
- [ ] Ensure future changes don't break save files (better error handling)
- [ ] Allow player to attach spells/equipment from inventory
- [x] Allow user to use keyboard to select targets in battle
# The List
## Battle (BATT)
- If attack inflicts a phobia or stat change and you want a hyperlink, it might be better to let the Formatters generate it for you.
	- Use `[url]` tag.
- `RichTextElement` can be used to set the color of elemental names.
	- To set the color of blank text, first character will need to be a " ".
### Actor Info (ainf)
**Show information about each actor:**
- [x] Name, Hp.
- [x] Current Element.
- [ ] Elemental Bias.
- [x] Status effects.
	- [x] Use 3d model pins instead of 2d sprites.
- [x] Stat changes.
- [x] Use 3d models instead of 2d sprites for characters.

### General Info (ginf)
**Show information about the following, when queried by player:**
- [x] Attack info.
- [x] Item info.
- [x] Battle Actor info.
- [x] Status conditions.
- [x] Debug info.
- [ ] Have beasiary/info book player can reference.
	- [ ] Hide info not yet discovered by player.

### Battle Logging (blog)
**Create detailed battle logs for diagnostic purposes.**
- [x] Status

### Action Selection (acse)
**Allow player to select, deselect, and submit actions.**
- [x] Player selects an action for each actor, moving from right to left.
- [x] Once an action is selected, UI automatically moves to next actor.
- [x] The player has the option to select different actions for previous actors.
	- [x] This should not cause the game to forget any other selected actions (e.g. Alice chooses attack, then Bob chooses attack. If player goes back to change Alices action, this should not deselect Bobs action).
- [x] Prevent player from selecting actions they do not meet the requirements for.
>[!bug]
>- [ ] Prevent player from double spending item. I.e. when two actors try to use the same item on the same turn.

### Turn Order (tuor)
**Calculate turn order based on actor's speed and action priority.**
- [x] Status

### Action Effects (acef)
 **Calculate and resolve attack/item effects.**
- [x] Damage.
- [x] Additional effects.
- [x] Apply affinity costs.
- [x] Remove item from inventory.

~~Both EffectSlot and AttackEffect have a Chance property. 
- If AttackEffect is damage, then  `EffectSlot.chance` is considered accuracy. This will fail with a message like "The attack missed."
- `AttackEffect.chance` will fail silently.
`Attack` and `EffectSlot` both have a `chance` property (called `accuracy` for Attacks).
- `_BaseEffectSlot.chance` will fail silently.
- `ConditionalEffectSlot` has a `print_failed_status` which can have values { SILENT, FAILURE, TOTAL_FAILURE }.
	- FAILURE prints a message if `ConditionalEffect.check` returns false.
	- TOTAL_FAILURE prints a message if `ConditionalEffect.check` returns false and failed_effect.apply_effect returns no output.
	- SILENT never prints a failed message.

StatChanges (v0.3.43)
- Instead of having a directory full of resources, StatChange effects are dynamically created by the attacks/etc that define them.
- The actual strength of a StatChange is calculated using `strength * MODIFIER` 
	- where MODIFIER is a constant currently set to 0.3.
#### Damage Calculation
- Damage calculation takes attacker's level into account, but not the defender's, biasing the result towards the attacker.
	- I could compensate by making the defense values generally higher than offense.
	- I could include the defender's level as well.
$$
Damage =  \left({strength +\frac{strength}{10}}\right) \times \frac{attack}{defense} \times affinity \times rand
$$
Where: 
- affinity = `Attack.scaling_factor`
	- This receives a 30% buff if the attack matches the user's alignment
- rand = $[0.8, 1]$
#### AttackEffect Internal Communication
- New `BattleAction.DataBuffer` class created. 
	 - `Data` will contain the BattleAction data, as well as a buffer `AttackEffects` can read/write to.
	 - `Data` can tell the current `AttackEffect` whether the previous effect was successful and how much damage it did, as well as the total damage done by the attack so far.
	 - `Data` is instantiated by the `Attack`. Most changes should be handled by the `EffectSlot`, except for damage (handled by `Damage`).
- This buffer can be read by any `AttackEffect` or `BaseEffectSlot`.
	- `BaseEffectSlot.chance` can read from this buffer.
- Syntax design requirements
	- Read from buffer.
*****	- Perform arithmetic operations on buffer data.
		- Buffer will be only variable, everything else will be literals.
	- Perform simple branching logic.
	- Write to buffer.
		- Simple output.
		- Overwrite buffer.
Advanced Syntax
``` 
TOKENS =  ADD, MUL, SUB, DIV, FLOAT, VARIABLE, PIPE, BUFFER_OP 

<cmd>   => <expression> [<pipe> <expression>]* <output>? | <value> <output>?
<output> => '>'<buffer_op>?
<buffer_op> => '+'|'-'|'*'|'/'|'0'
<pipe>  => '|'

<expression> => <op> <value> <value> | <op> <value>
<op> => 'add' | 'mul' | 'sub' | 'div'
<value> => <variable> | <float>
<variable>   => '$' | '$d' | '$t'
 	'$': Read direcly from previous pipe. If used in first expression, reads from buffer.
 	'$d': Read from amount of damage dealt by last attack.
 	'$t': Read from total amount of damage dealt by attack so far.
<float>  => [0-9]*(\.[0-9]*)
```

```
EXAMPLE DrainingDamage
BUFFER = $ = 100     # Damage done by previous effect
strength = div $ 10  # Strength is equiv to 10% of damage done previously
				|
				V
strength: get = func calc_strength(damageDonePrev: float) -> float:
	return damageDonePrev / 10.0

class AttackEffect:
	var read_from_buffer: bool
	var current_buffer: DataBuffer
	var buffer_map: Dictionary[String, Callable]
	
	func modded_get_strength():
		return buffer_map("strength").call(current_buffer)


EXAMPLE OUTPUT
div $ 10
	func cmd(buffer: DataBuffer) -> float:
		return div.bind(10.0).bind(buffer.buffer) # returns buffer.buffer / 10
mul $ 10 | sub 1
	func cmd(buffer: DataBuffer) -> float:
		return sub.bind(1).bind()
```
#### AttackEffect External Communication
To get info about the battlefield state, objects will reference the `Battle` singleton. Specifically, the `ReaderSlot` will read the state and write to the `DataBuffer` mentioned above. This object will be of type `BaseEffectSlot`, but will not apply any effects to any combatants.

Unlike the previous section, these will use a more traditional inheritance structure.
### Transmutations (tran)
**Apply transmutations and related effects when necessary.**
- [x] (Primary | Secondary) + Attack
- [x] Primary + Secondary
- [x] Apply side effects.

### Animations (anim)
**Allow attacks to play unique animations.**
- [x] Status

### Effect Expirations (efex)
**Remove expired status conditions and stat changes.**
- [x] Status

### End Battle (enba)
**End battle when player runs away or a team is defeated.**
- [x] Reset stat boosts and status effects
- [ ] Give exp to player
- [ ] Optionally give loot to player
- [ ] Display player's battle rewards
	- [ ] Loot
	- [ ] Exp and exp until next level
	- [ ] On levelup, show stat changes
- [ ] Give player stat boosts upon level up

Each stat has the following components:
- Base total
- Mod total: Stat buffs/debuffs, reset after battle
- Xp: This value will be added to the stats upon level up

Player characters will have their own unique `StatManager` class, which include this last value (xp). Stat changes will be calculated based on the side effects a character accrues before level up. The `PlayerStatManager` will store how much each stat has been boosted.
- Should debuffs affect these values?
- How should the StatManager tell the difference between transmutation side effects and regular stat buffs?
	- Instead of using a regular `StatChange`, a new child class could be created specifically to handle side effects.
- Should anything else factor into these calculations? This current concept would ensure both attacks and defenses would rise together.
	- The player's affinity values (which are also calculated at the end of battle) could contribute to the xp values.
	
*During battle*: StatManager keeps track of cumulative side effects. 
*After battle*: AffinityManager informs StatManager of how many times each transmutation occurred.
*Upon level up*: StatManager adds each xp value to its associated stat. Decimal values roll over to next level.

>[!note] 
>The AlignmentManager (AffinityManager) is only given to player characters. It might make sense to have it take care of level up logic, especially since its already running calculations at the end of every battle.
	
**Option 1**

| Element  | Hp  | Melee Attack | Melee Defense | Ranged Attack | Ranged Defense | Speed |
| -------- | --- | ------------ | ------------- | ------------- | -------------- | ----- |
| Blue     | x*  |              | x             |               |                |       |
| Purple   |     |              |               | x             | x              |       |
| Magental | x   |              | x             |               |                |       |
| Red      | x   | x            |               |               |                |       |
| Orange   |     |              |               | x             |                | x*    |
| Yellow   |     |              |               |               | x              | x     |
| Green    |     | x            |               | x             |                |       |
| Cyan     |     |              | x             |               | x              |       |
\*Stat selected for balancing reasons more than lore.

**Option 2**

| Element | Hp  | Melee Attack | Melee Defense | Ranged Attack | Ranged Defense | Speed |
| ------- | --- | ------------ | ------------- | ------------- | -------------- | ----- |
| Blue    | x*  |              | x             |               |                |       |
| Purple  |     | x            |               | x?            | x              |       |
| Magenta | x   |              | x             |               |                |       |
| Red     | x   | x            |               |               |                |       |
| Orange  |     |              |               | x             |                | x*    |
| Yellow  |     |              |               |               | x              | x     |
| Green   |     | x            |               | x             |                | x?    |
| Cyan    |     |              | x             |               | x              |       |
\?Element has 3 stats it influences.

**Implementation Notes**
- SideEffect.strength is totalled up until level up. The integer portion of this value is added to each stat upon level up.
- Every transmutation is added to running totals as well, using the rules shown in the option 2 table above.
- When leveling up, stat boosts cannot exceed 10% of their current base stats. If this cap is reached, half of the unused stat boosts will roll over to the next level. This way if the player has a lot of stat boosts over the course of their level up, they won't get game breaking changes.
- Currently there is an issue where,  if the player hasn't transmuted much, they won't get many stat boosts. ~~I have two ideas on how to address this:~~
	- First, at end of battle, player receives stat xp bonuses based on their current elemental state.
	- If battle is completed under a certain number of turns, each BattleActor will receive bonus stat xp based on their final elemental state.
**Right before battle ends**
1. At end of battle, `BattleActor.resolve_end_of_turn(...)` is called.
2. `AlignmentManager` normalizes values and calculates alignment.
3. `AlignmentManager` informs `PlayerStatManager` of how many times each transmutation occurred.

**After battle ends**
1. `Battle` instantiates `RewardScreen`.
2. `Battle` calls `RewardScreen.show_results(BattleActor[], xp, ItemSlot[])`
3. `RewardScreen` displays `BattleActor` info.
4. `RewardScreen` calls `BattleActor.add_xp(...)` and `BattleActor.level_up(...)`.
5. If necessary, update `RewardScreen`.
6. Force PlayerScreens to refresh.

### Attack Creator (atcr)
**Have means to quickly create new attacks both in-game and in-engine.**
- [x] Select required attributes: Name, Element, Priority, Range, Target, Cost. 
- [ ] Fill out optional details section.
- [ ] The following attributes will need to be manually filled out or give the user access to the filesystem: Animation, AttackEffects.
- [ ] Allow the user to create 1+ Effects.
	- [ ]  Chance.
	- [ ]  Target.
	- [ ]  AttackEffect.
## Overworld (OVER)
>[!important] 
> Players collision layer is 1.
> Projectile collision layer is 2.
> MagiClay collision layer is 3.
> Laser collision layer is 4.
>- Things that block lasers are on layer 5.
> - Layer 6 is for things that only affect the player.
> Water collision mask is 7.
> - Anything that interacts with water be on layer 7.

### Water
- Player will return to last stable position
- MagiClay will return to its spawn position
- Water that Blue golems can walk through should have a static body slightly underneath
### Character Controller (chco)
**Player should be able to perform simple actions:**
- [x] Walking/running.
- [ ] Jumping
- [x]  Pickup objects and place in inventory.
- [x] Open chests.
- [x] Drag objects.
- [ ] Each player action should have corresponding animations.

#### Grabbables
In v0.3.26, all interactable objects were managed thru a child (the grabbable). I find this system clunky.

I think grabbables are fine as a method of iterating is fine, when its one off. I.e. a sort of button, where the player presses it, is suited for the grabbable. Draggable items, however, should likely be managed by a different mechanic.

For v0.3.27:
- Grabbable => Interactable
	- Dropped signals and plumbing removed.
	- When player interacts with object, emit one-and-done signal.
- Draggable created
	- Must be child of object it moves.
		- MagiClay.puzzle_name would be broken.
		- It would obscure the names of the important objects in the scene tree.
	- When player interacts, control should be passed to Draggable.
		- Both Draggable.parent and player is changed to be the children of Draggable.
		- In this state, Draggable.collision_layer.6 is set to true. This ensures the Chunk remains loaded.
For v0.3.45:
- Idea \#1: I think it would be cool if, when the player opens a chest, a menu opens up showing its contents. The player can choose which items to select and view their descriptions. Admittedly, this is mostly for my current concept of the opening scene, where the player opens their fridge and finds the takeout container.
- Idea \#2: A menu screen similar to idea \#1, but instead of allowing the player to not select items, instead just allows them to read the item descriptions.
I think idea \#2 would fit better with the currently designed systems.
### Player Companions (plco)
**The player's current companions should have overworld models that follow the player, without getting in the way.**
- [ ] Status

### Overworld Spells (spel)
**Player should have overworld spells which can be used to get around obstacles.**
**Physics system**
- [x] Should utilize Godot's existing systems.
- [x] Should integrate with the chemistry and puzzle block systems.
- [x] Allow player to select up to 2 overworld spells to use at a time.
	- [x] A graphic should be used to show which 2 overworld spells are currently selected.
- [ ] New overworld spells should be able to be added in 1-2 steps.

### Chemistry System/MagiClay (clay)
**The transmutation mechanic should be included in the overworld, not just in battle.**
- [x] Certain physics objects should be assigned an elemental type.
- [x] Some of these objects should be targetable by the overworld spells.
- [x] There should be the option to toggle whether each spell can effect an object.
- [ ] There should be a visual indicator of which objects can be targeted by which spells.
- [ ] These visual indicators shouldn't interfere with each other, if a single object can be targetable by multiple spells.
- [ ] Different elements should have unique physical properties.
	- Magenta: Bouncy
	- Cyan: Frictionless
	- Yellow: Antigrav
	- Blue: Heavy/high inertia
	- Red: Biological => What this means exactly is TBD.
	- The rest have to be 'refined' in order to display their unique features, restricting them to machines/etc. 

I think the physical properties idea is excellent in theory, but has proven an absolute pain to implement. I also suspect it might have some performance issues. There are two approaches I could take to address this:
- Implement a physics system in C++ from the ground up.
- Restrict this aspect to 'refined matter,' allowing me to control which objects/machines are affected by transmutations.

The issues arise between the player controller, Draggables, and the interaction between MagiClay objects.
- If the player is a RigidBody the Chemistry system is more interactable and natural, but Draggables break.
- Using a CharacterBody allows the Draggables to work, but makes interacting with the system difficult.
- Since the player cannot jump, their ability to interact with these physics effects are limited.

### Puzzle Blocks (publ)
**Puzzles should be designed using simple building blocks.**
- [x] Light up wire should show how different puzzle blocks are connected and whether they are active.

>[!important] Delays and Pressure plates
>Delays and pressure plates do not work together well. When the player drops a block on the pressure plate, it temporarily exits the tree. When it reenters, it does not reactivate the delay.
### Puzzle Archetype (puar)
**Puzzles should follow different archetypes that expand on each other.**

### Wild Enemies (wild)
**Wild enemies should spawn inside defined areas of the map.**
- [ ] Wild enemies should have overworld models.
	- [ ] These models should show some information about the enemies involved (e.g. their starting typing, difficulty).
	- [x] When the player collides with these models, a battle should commence.
- [x] Spawner fields should be used to control what can spawn and where.
	- [x] A Spawner should be given a list of BattleActors, which act as the base template for each enemy that can spawn.
	- [x] When an enemy is instantiated, its stats should be subject to some amount of variance.
- [x] Wild enemies should be physics objects.
- [ ] Different enemies should have different overworld behavior.
	- [x] Chasing player.
	- [ ] Charging at player.
	- [ ] Fleeing from player.
	- [ ] Attacking other wild monsters.
	- [ ] Not attacking the player unless they interact, instead of on collision.
- [ ] Enemies should have customizable behavior in battle.
	- [ ] A simple integer slider should be used to set their general difficulty.
	- [ ] Opponents should have some ability to use different tactics.

Wild Monster components:
- BattleActor
- Spawner setup
- Overworld
- Beastiary entry

Beastiary will be a singleton. WildEnemyActors and Battle will obtain their relevant data using their monster_id.
## Character Management and Inventory (CHAR)
### Pausing Game (paus)
**Opening a menu should pause overworld/game.**
- [x] Status
### Save and Load Game (save)
**Player should have ability to save/load games.**
- [x] Player can save games under unique names.
- [x] Player can load previously saved games.
- [x] Objects can determine whether or not they should be saved.

All objects that can be saved must be added to the `persist` group.
All nodes in this group must have the following 2 methods:
- `dict serialize()`
- `void deserialize(data: dict)`
The `dict` returned by `serialize()` must have a `path` field.

The `SaveMenu` keeps track of which `persist` items are deleted using `queue_free()` or similar means. When a save file is loaded, the `SaveMenu` calls `queue_free()` on all of these nodes. This is done during the ready phase, so if nodes are instantiated later on, they will not included. I don't think this will be a problem.

`Chunk`s can be added to the `persist` group. If they are, they will automatically handle all of their serializable children. To avoid double saving, `Chunk`s will remove all their children from this group.

When loading a saved game, the current game state should be reset. This is done by calling `get_tree().reload_current_scene(); await get_tree().create_timer(1.0).timeout`. This will not reload any singletons! All singletons that are part of the `persist` group will have this reloading handled by their deserialize functions.
# ## Settings Menu (sett)
**Player should have access to settings menu.**
- [x] Status
See [[#Settings and Accessibility (ACCS)]] for more details.
### Party Info (pinf)
**Player should be able to view information about their current party.**
- [x] Name.
- [x] Current primary and secondary typing.
- [x] Bias, if any.
- [ ] Level and experience.

### Stat Management (stat)
**Player should have a way to distribute stat points when they level up.**
- [ ] Player should gain experience from battles.
- [ ] Upon gaining a threshold of experience, player should level up.
- [ ] Leveling up should boost player and partner's base stats.
- [x] Character level should be used in damage calculations.

### Item Management (iman)
**Player should be able to view and use items in their inventory.**
- [x] Player can view items inside their inventory.
- [ ] Player can sort inventory by item id or alphabetically.
- [ ] Player can select items from their inventory to use.
- [x] Inventory hides items the player has none of.
- [x] Player can open chests which add items to their inventory.
- [ ] NPCs can add/remove items from inventory.
- [ ] Vendors can buy/sell items with the player.

### Spell Management (sman)
**Player should be able to manage their current spell movesets.**
- [x] Teach character a new spell.
	- [x]  Require player to have proper SpellScroll available.
	- [x] Ensure character meets item requirements.
	- [x] Ensure player meets quantity requirements.
- [x] Remove spell from moveset.
- [ ] Reorder spells in moveset.
- [x] Replace spell.
	- [x] From inside character management menu.
	- [ ] From inside inventory menu. 

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
4. Player confirms which spell/equipment to replace.
5. Modify `BattleActor`.
6. `CharacterScreen` (which listens for changes to `BattleActor`) updates GUI.
### Alignment Manager (alig)
- [ ] Update alignment values after every battle for all player characters.
	- [ ] Using an attack. This value should be normalized after every battle.
	- [ ] Transmuting into an element. This value should be normalized after every battle.
	- [ ] Developing a phobia -1. This value is NOT normalized.
- [x] Prevent character from aligning with an element, if they already have an alignment.
- [ ] Ensure character's alignment and primary type match.

## Settings and Accessibility (ACCS)
### Keybindings (keyb)
**Allow player to reassign keybindings.**
### Colorblindness (colb)
- [x] Allow RGB values for each Element to be changed.
- [ ] Provide RGB presets for colorblind players.

*The next system was created as a naive solution. Godot has a theming system which can likely do this better and should be used where possible.*
- This works for things like Buttons, but not ColorRects.
- This will also not work for MagiClay.
*The Naive Solution*
- All text that changes its color based on its element should be styled using the `[el]` bbcode tag.
- The following `Control` nodes can use the `elemental_gui` tag directly to update their value. If it does, it should be given a piece of metadata of type with name="ELEMENT" and value: char = first letter of element name in uppercase.
	- ColorRect
	- Button


### Localizations (locl)
**Allow for localizations of text and dialog.**
## Story and Content (STRY)
- Npc nodes can have `StoryActor`, `EnemyActor`, `VendorActor` children.
	- If no StoryActor or VendorActor children exist, but an EnemyActor does, colliding with this npc will start a battle.
	- Otherwise, Npc checks if player is nearby, displaying prompt to talk if they are.
	- If player presses interact button, Npc uses `player.call_deferred` to instruct player node to start dialog or battle.
- Player emits appropirate signal, which is picked up by the `OverworldConnector`.
- OverworldConnector pauses overworld and displays dialog.
- If this Npc has a cutscene that should play while they are talking:
	- Npc.storyactor should have an `AnimationPlayer` child containing the cutscene.
	- The appropriate dialog tree should have a `SetNode` which sets a value for "current_cutscene". The value should match the name of the animation inside of the `AnimationPlayer`.
		- This `SetNode` should feed directly into a `SignalNode` which emits the "play_cutscene" signal.
	- AnimationPlayer.process_mode should be set to Always. None of the nodes it controls need this attribute.
	- **There is now a SetSignalNode added to accomplish this with just one node.**

To manage a character who has multiple dialog trees, there are a few options:
1. StoryActor stores its dialog_ids in a list. Each item in the list has a string `id` and an int `next`. If `next==-1`, then the current dialog will loop. Otherwise, its treated as the next index to start dialog at.
2. The DialogueNodes addon has the ability to set and check variables. **This is the preferred option.**

TODO:
- [x] Allow StoryActors to share AnimationPlayers.
- [x] Allow StoryActor to trigger animations directly.

### Dialog (dial)
**Display dialog when player talks to character.**
- Allow characters to vary dialog based on :
	- Number of times player has talked to them.
	- Story events that have/have not happened.
	- Answers player has previously given them.
	- Items in player's inventory.
	- If the player has defeated them in battle.
### Story Manager and Events (even)
- Communicate specified story vars between DialogueData objects.
- ~~Facilitate StoryEvents.
	- ~~Trigger.
	- ~~Effect.

_StoryEvent_
- Set variable.
- Add/remove items from inventory.
- Add/remove companion => **This can be done using AnimationPlayers.**
### Story Triggers (trig)
- [x] Trigger story event when player steps on a specific spot in world.
- [x] Trigger story event when player talks to specific character.

StoryTriggers are triggered by having an Npc node with `Npc.auto_trigger = true` and with a `StoryActor` or `AnimationActor` child. 
- `StoryActor` is for events that have any dialog.
- `AnimationActor` is for events with no dialog. They can be blocking (prevent player input) or non-blocking.

>[!important] 
>If `Npc.auto_trigger = true` and both a `StoryActor` and `AnimationActor`, the `AnimationActor` will take priority.
### Quest System (ques)
- [ ] Assigned to player by another character or a StoryEvent.
- [ ] Show player a list of their active, expired and completed quests.
- [ ] Remove expired quests.
### Write and Design Content (writ)
- Content
	- Level design
	- Asset design
	- Bestiary
	- Items and attacks
- Story
	- Dialog.
	- Character bios.
	- Main plot and side quests.
## Polish and Aesthetics (POLI)
Misc
- 3D
	- Modeling
	- Texturing
	- Animation
- 2D
	- Character dialog sprites
	- Icons and graphics
	- GUI Theming
- Audio
	- Music
	- Sound effects
### Achievements (achi)
**Give the player rewards/badges for completing certain objectives.**
- [ ] Allow easy addition of achievements for arbitrary game states.
- [ ] Have achievements sync with steam library/etc.
### Assets (asst)
#### Art Direction
I want the game as a whole to have an arts-and-crafts aesthetics. The assets should look like they were gathered to make a stop motion animation.

[Clay Doh](https://blendermarket.com/products/claydoh) by DoubleGum is a procedural shader pack that gives objects a clay-like material. It cost $30 and contains 13 different materials presets, which I personally think is a great deal. It has a royalty-free license as well.

Since using claymation textures has a bit more of an indepth workflow, requiring a normal and diffuse map for every surface, which in turn must be baked every time they are updated, I only plan to use these for more important assets. 
- Characters
- Large environmental set pieces

For small decorative assets, a more plasticky texture should be used. Blender's `Principled BSDF` will transfer automatically to Godot, but most other nodes will not. So the workflow for these assets will be as follows:
- Set albedo color inside Blender using `Principled BSDF`.
- After texturing and modeling is done, add roughness map inside of Godot.
	- Make mesh and material unique.
	- Add NoiseTexture to `roughness_texture`.
	- Add noise value to texture.
- ~~If model and/or material is changed in Blender, the object in Godot must be deleted and added back.~~ Changing the model/material will revert the mesh to its original state. To manually reset it, press the reset button next to mesh in inspector.