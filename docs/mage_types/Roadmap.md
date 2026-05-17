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
- v0.6.x: [[more_dynamic_battles]]
# Objectives
- Refine design processes
	- 3 types of updates
		- Mechanic
		- Content
		- Aesthetic
- Practice making challenges
# Upcoming Versions
[[version_naming_scheme]]

#v0_7: Tutorial Visual Polish
#v0_8: Audio polish
#v0_9: GUI and Settings
# The List
## Bugs
- [ ] When player is defeated in battle, it immediately ends before playing animations, etc
- [ ] Alignment calculations at end of battle crashing due to empty list of elements
- [ ] Falling animation playing when going thru doorways
## Battle 
- If attack inflicts a phobia or stat change and you want a hyperlink, it might be better to let the Formatters generate it for you.
	- Use `[url]` tag.
- `RichTextElement` can be used to set the color of elemental names.
	- To set the color of blank text, first character will need to be a " ".
### Communicating Info to Player
- [x] Show information about each actor
	- [x] Name, Hp.
	- [x] Current Element.
	- [x] Elemental Bias.
	- [x] Status effects.
		- [x] Use 3d model pins instead of 2d sprites.
	- [x] Stat changes.
	- [x] Use 3d models instead of 2d sprites for characters.

- [ ] Fresnel shader #v0_7 
	- [x] Test to ensure shader works with more complicated models
	- [x] Dynamically change battle sprite albedo using fresnel effect
	- [x] Ensure each battle actor has their own instance of shader
	- [ ] Fade between default texture and fresnel when battle starts
	- [ ] Animation when character is defeated, burst

- [x] Show information about the following, when queried by player
	- [x] Attack info.
	- [x] Item info.
	- [x] Battle Actor info.
	- [x] Status conditions.
	- [x] Debug info.
	
- [x] Create detailed battle logs for diagnostic purposes.

- [ ] Allow player to select, deselect, and submit actions.
	- [x] Player selects an action for each actor, moving from right to left.
	- [x] Once an action is selected, UI automatically moves to next actor.
	- [x] The player has the option to select different actions for previous actors.
		- [x] This should not cause the game to forget any other selected actions (e.g. Alice chooses attack, then Bob chooses attack. If player goes back to change Alices action, this should not deselect Bobs action).
	- [x] Prevent player from selecting actions they do not meet the requirements for.
	- [ ] **Bugfix**: Prevent player from double spending item. I.e. when two actors try to use the same item on the same turn.

- [x] Calculate turn order based on actor's speed and action priority
	- [x] Display speed ranking 
	- [ ] Speed ranking/turn order accounts for priority
	
- [ ] Make controls less obtrusive
	- [x] Attack, Item, and Run buttons should be small and off to the side
	- [ ] InfoDisplay
		- [ ] Hovering should highlight which name card is theirs
		- [x] Player can click on a BattleActor model to display info about them
		- [x] Hovering over status pin should tell you what it is and how many turns remaining it has
			- [ ] Hovering status pin should outline that pin
### Action Effects 
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
### Aesthetics
See also: [[more_dynamic_battles]]
- [x] Allow attacks to play unique animations.
- [x] Battle models animations backend support
	- [x] Idle
	- [x] Channeling 
	- [x] Attack
	- [x] Getting hit
- [x] Animation for status effects proc
- [ ] Battle music
- [ ] Battle sound effects
	- [ ] Attack missing
	- [ ] Attack landing
	- [ ] Channeling
	- [ ] Status Effect being inflicted
	- [ ] Status Effect proc
- [ ] Setting to control speed and turn off animations
- [ ] Use buttons to skip battle animations
- [ ] Attack Animation refactor
	- [ ] Renamed class and references
	- [ ] Animation should be selected via enum
	- [ ] Animation should be integrated with BattleActor animations
### Misc Mechanics
- [x] Remove expired status conditions and stat changes.
- [x] Apply transmutations and related effects when necessary.
	- [x] (Primary | Secondary) + Attack
	- [x] Primary + Secondary
	- [x] Apply side effects.
### End Battle
**End battle when player runs away or a team is defeated.**
- [x] Reset stat boosts and status effects
- [x] Give exp to player
- [x] Optionally give loot to player
- [x] Display player's battle rewards
	- [x] Loot
	- [x] Exp and exp until next level
	- [x] On levelup, show stat changes
- [x] Give player stat boosts upon level up

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
\*Stat selected for balancing reasons more than lore.

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

### Attack Creator
**Have means to quickly create new attacks both in-game and in-engine.**
*This uses the DBMS Addon I created, which is also used to manage Inventory/items*
AttackManager can set the following values:
- Name
- Element
- Range
- Targets
- Priority
- Power
- Accuracy
- Scaling
- Description
Everything else must be managed traditionally
### Dual Combat System
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
## Elemental System
- [ ] Add tutorial for transmutation map
- [ ] Associate symbols with each element to help with differentiation
- [x] Use proper enum instead of `@export_enum`
- [x] Add missing reactions and recreate transmutation chart
	- [x] Orange + Cyan = Green
	- [ ] Yellow + Purple = Red
		-  Adding this reaction would make 3 reactions involving Yellow + ??? = Red, which further clutters the transmutation map. This and the fact that it doesn't quite visually look right makes me tempted to nix it. 
		- This would also eliminate the intersection
- [x] Adjust `ElementalType.main_color` values
## Player
 - [x] Player should be able to perform simple actions:
	- [x] Walking/running.
	- [x] Jumping
	- [x]  Pickup objects and place in inventory.
	- [x] Open chests.
	- [x] Drag objects.
- [x] Each player action should have corresponding animations. #v0_7
	- [x] Idle
		- [x] space weight shifting out more
	- [x] Walk
		- [x] Get feedback, I can't tell what's off
			- I think I fixed it (broadstrokes), so it can wait until I get feedback for the rest
	- [x] Jump
	- [x] Dash
		- Removed dash, as I didn't like how it looked
- [x] Player battle animations
	- [x] Channeling
	- [x] Attack
	- [x] Getting hit
	- [x] Battle idle
- [ ] Player Audio FX #v0_8 
	- [ ] Footsteps
	- [ ] Dash and jump sounds
- [x] Textures
	- [x] Compare NextPassTransparency with Swapping diffuse maps
		- Swapping diffuse maps looks far better than the next pass method
	- [x] Retexture: Due to the new battle shader, I can now use more subtle color palettes #v0_7
		- [x] Change primary/secondary color dynamically
			- [x] Skin is primary color
			- [x] Hair highlights are secondary
		- [x] Color palette selection and assignment
		- [x] Bake textures
	- [x] BugFix: Adjust weight painting for shoulders, so they stop clipping through jacket #v0_7
### Playable Character Shader
- [x] Dynamically change aspects of a character's color palette to match their current typing
`PCShaderManager: Node3D` 
`PCShader: Shader`
`ElementMap: TextureMap`

`ElementMap` will use *red* channel to encode primary type influence and *green* to encode secondary. The *blue* channel will encode whether this pixel is affected by an elemental color and is used to weight the default diffuse map.
- Primary color will be *magenta* on the map
- Secondary color will be *cyan*
- No change will be *black*

>[!note] Creating ElementMap in Blender
> 1. MixColor node selects between diffuse and element colors
> 2. Create a float value in ~~Materials~~ Data menu called 'element_map' (or something similar)
> 	1. Putting it in Materials menu means you have to switch to that specific material to see it. It'll work either way, its just a QOL note.
> 3. Paste driver onto factor field on MixColor node
>    
> This way, color sets can be easily swapped between when baking.

To use this shader to a model in Godot, assign `character_clay.gdshader` to the mesh's `material_override` slot. Then assign all of its texture maps. Finally, add and `PCElementShaderManager` node to its scene, assigning its `BattleActor` and `Mesh`.
### Partners
**Alice**: The player's main companion and only currently partner planned.
- [x] Design
- [x] Modeled
- [x] Texture maps
- [x] Animations
### Grabbables
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
### Player Companions 
- [ ] The player's current companions should have overworld models that follow the player, without getting in the way.
- [ ] Alice character model which follows player
- [ ] Should match player's speed to avoid getting left behind
- [ ] Should not block/collide with player
## Overworld 
>[!important] 
> Players collision layer is 1.
> Projectile collision layer is 2.
> MagiClay collision layer is 3.
> Laser collision layer is 4.
>- Things that block lasers are on layer 5.
> - Layer 6 is for things that only affect the player.
> Water collision mask is 7.
> - Anything that interacts with water be on layer 7.

- [x] Water
	- [x]  Player will return to last stable position
	- [x]  MagiClay will return to its spawn position
	- [x] Water that Blue golems can walk through should have a static body slightly underneath

### Overworld Spells
**Player should have overworld spells which can be used to get around obstacles.**
**Physics system**
- [x] Should utilize Godot's existing systems.
- [x] Should integrate with the chemistry and puzzle block systems.
- [x] Allow player to select up to 2 overworld spells to use at a time.
	- [x] A graphic should be used to show which 2 overworld spells are currently selected.
- [x] Equipment/Overworld spell refactor
	- [x] Redo related UI screens
	- [x] Player can select between Battle and Overworld equipment
	- [x] Partners only have overworld equipment
	- [x] OverworldSpellManager is easier to extend
		- [x] Player can equip/unequip overworld spells
	- [x] Add enemy encounters
- [ ] Bugfix: Spells can only be targeted/cast when mouse is over collision body
	- [ ] Raycast to plane level with player
- [x] Refactored overworld spell logic
	
>[!help] Adding New Overworld Spells
>1. Create new node/script inheriting from `OverworldSpell`
>2. Inside script, add spell logic
>3. Add node as child of `SpellManager`
>4. Add entry to `SpellManager.spell_mapper` to associate spell with `Equipment`
### Chemistry System (MagiClay)
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

>[!warning] 
> I think the physical properties idea is excellent in theory, but has proven an absolute pain to implement. I also suspect it might have some performance issues. There are two approaches I could take to address this:
> - Implement a physics system in C++ from the ground up.
> - Restrict this aspect to 'refined matter,' allowing me to control which objects/machines are affected by transmutations.
> 
> The issues arise between the player controller, Draggables, and the interaction between MagiClay objects.
> - If the player is a RigidBody the Chemistry system is more interactable and natural, but Draggables break.
> - Using a CharacterBody allows the Draggables to work, but makes interacting with the system difficult.
> - Since the player cannot jump, their ability to interact with these physics effects are limited.
### Puzzle Blocks 
[[PuzzleBlocks]]
- [x] Puzzles should be designed using simple building blocks.
	- [x] Light up wire should show how different puzzle blocks are connected and whether they are active.
>[!important] Delays and Pressure plates
>Delays and pressure plates do not work together well. When the player drops a block on the pressure plate, it temporarily exits the tree. When it reenters, it does not reactivate the delay.

### Wild Enemies 
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
- [ ] Have beasiary/info book player can reference.
	- [ ] Hide info not yet discovered by player.
### Interactables
- [ ] Opening chests should show player list of contents and allow them to individually select them
- [x] Key/lock system
### Map
- [x] Create map menu
- [x] Add support for multiple maps (beach, hotel, etc)
	- [x] Arrows indicate how areas are connected 
	- [ ] Clicking on arrow should automatically open that map
- [ ] Map menu improvements
	- [ ] Icon showing which room player is in (use Player.active_chunk)
	- [ ] Ability to write on map?
## Character Management and Inventory 
- [x] Opening a menu should pause overworld/game.
### Save System
- [ ] Player should have ability to save/load games.
	- [x] Player can save games under unique names.
	- [x] Player can load previously saved games.
	- [x] Objects can determine whether or not they should be saved.
	- [ ] Add better error handling to make saves backwards compatible

All objects that can be saved must be added to the `persist` group.
All nodes in this group must have the following 2 methods:
- `dict serialize()`
- `void deserialize(data: dict)`
The `dict` returned by `serialize()` must have a `path` field.

The `SaveMenu` keeps track of which `persist` items are deleted using `queue_free()` or similar means. When a save file is loaded, the `SaveMenu` calls `queue_free()` on all of these nodes. This is done during the ready phase, so if nodes are instantiated later on, they will not included. I don't think this will be a problem.

`Chunk`s can be added to the `persist` group. If they are, they will automatically handle all of their serializable children. To avoid double saving, `Chunk`s will remove all their children from this group.

When loading a saved game, the current game state should be reset. This is done by calling `get_tree().reload_current_scene(); await get_tree().create_timer(1.0).timeout`. This will not reload any singletons! All singletons that are part of the `persist` group will have this reloading handled by their deserialize functions.
### Party Management
- [x] Player should be able to view information about their current party.
	- [x] Name.
	- [x] Current primary and secondary typing.
	- [x] Bias, if any.
	- [x] Level and experience.
- [x] Player should have a way to distribute *stat* points when they level up.
	- [x] Player should gain experience from battles.
	- [x] Upon gaining a threshold of experience, player should level up.
	- [x] Leveling up should boost player and partner's base stats.
	- [x] Character level should be used in damage calculations.
- [ ] Alignment Management
	- [x] Update alignment values after every battle for all player characters.
		- [x] Using an attack. This value should be normalized after every battle.
		- [x] Transmuting into an element. This value should be normalized after every battle.
		- [ ] Developing a phobia -1. This value is NOT normalized.
	- [x] Prevent character from aligning with an element, if they already have an alignment.
	- [ ] Ensure character's alignment and primary type match.
### Inventory and Spells
- [ ] Player should be able to view and use items in their inventory.
	- [x] Player can view items inside their inventory.
	- [ ] Player can sort inventory by item id or alphabetically.
	- [ ] Player can select items from their inventory to use.
	- [x] Inventory hides items the player has none of.
	- [x] Player can open chests which add items to their inventory.
	- [ ] NPCs can add/remove items from inventory.
	- [ ] Vendors can buy/sell items with the player.

- [ ] Player should be able to manage their current spell movesets.
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
### Scrapbook
- [ ] Scrapbook containing hints and notes the player has found
	- Notes can be obtained by interacting with parts of the environment. Diagetically, they are written on some form of carbon-paper sticky notes, allowing the player to take more than one copy of the same note. 
	- [ ] Notes can be obtained from overworld
	- [ ] Notes can be reorganized
	- [ ] Notes can be deleted
	- [ ] Player can create notes and drawings on notebook pages
## Settings and Accessibility 
- [ ] Allow player to reassign keybindings.

- [ ] Colorblind settings #v0_9
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
	
- [ ] Allow for localizations of text and dialog.
- [ ] Use Godot Theme system to make GUI more uniform
- [ ] Display settings #v0_9
	- [ ] Resolution
- [ ] Audio settings #v0_9
	- [ ] Master volume
	- [ ] Music volume
	- [ ] SFX
- [ ] Gameplay #v0_9
	- [ ] Show transmutation hints
	- [ ] Difficulty
## Story Management
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

- [x] Allow StoryActors to share AnimationPlayers.
- [x] Allow StoryActor to trigger animations directly.
### Dialog
- [ ] Display dialog when player talks to character.
	- [ ] Allow characters to vary dialog based on:
	- Number of times player has talked to them.
	- Story events that have/have not happened.
	- Answers player has previously given them.
	- Items in player's inventory.
	- If the player has defeated them in battle.
- [ ] Integrate my fork of DialogueNodes 
- [x] Communicate specified story vars between DialogueData objects.
### Story Events and Quests
- [x] Story Events
	- [x] Trigger story event when player steps on a specific spot in world.
	- [x] Trigger story event when player talks to specific character.
	- Set variable.
	- Add/remove items from inventory.
	- Add/remove companion => **This can be done using AnimationPlayers.**

StoryTriggers are triggered by having an Npc node with `Npc.auto_trigger = true` and with a `StoryActor` or `AnimationActor` child. 
- `StoryActor` is for events that have any dialog.
- `AnimationActor` is for events with no dialog. They can be blocking (prevent player input) or non-blocking.

>[!important] 
>If `Npc.auto_trigger = true` and both a `StoryActor` and `AnimationActor`, the `AnimationActor` will take priority.

- [ ] Quest System
	- [ ] Assigned to player by another character or a StoryEvent.
	- [ ] Show player a list of their active, expired and completed quests.
	- [ ] Remove expired quests.
## Content
[[art_direction]]
 - [ ] Achievements
	- [ ] Allow easy addition of achievements for arbitrary game states.
	- [ ] Have achievements sync with steam library/etc.
- [ ] Beastiary describing monsters
- [ ] Materials and textures
	- [ ] Clay shader cracks are inverted?
		- Ensure normals are correct
	- [ ] Revisit clay shader. GDShader version should ideally be indistinguishable from the blender one
	- [ ] PrincipledBSDF should have a plasticky look
### Misc Areas
- [ ] Hallways #v0_7
	- [ ] Wallpaper
	- [ ] Assets made out of clay or plastic
	- [ ] Local lighting
	- [ ] Ambient sounds #v0_8 
		- [ ] Ice Machine #v0_8 
	- [ ] Ambient music #v0_8 
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
	- [ ] Give Rail puzzleblock a model
	- [ ] Add models for empty puzzle blocks?
- [ ] Replace placeholder door blockers/etc with models and diagetic explanations.
	- [ ] Add colliders and "Wet floor signs" to block access to Purple and Pools
	- [ ] Add out-of-order elevator to final pillar in ziggurat room
	- [ ] On doors player cannot enter, add "Do not disturb" signage
- [ ] Create door models and animations
	- [ ] Delay/animation before returning control to player? This would be necessary if rotating player model to face away from door
### Beach
- [ ] Wave ambience #v0_8
- [ ] Beach 1 #v0_7
	- [x] Layout
	- [x] Modeling
	- [x] Texturing
		- [x] Adjust colors
	- [ ] Fix holes in model exposed during waves
	- [ ] Fix water texture
	- [ ] Fix pier collider and materials
- [ ] Beach 1 backtracking puzzle
- [ ] Beach 2 #v0_7
	- [x] Layout
	- [x] Modeling
	- [ ] Textures
	- [ ] Decor assets
- [ ] Beach house #v0_7
	- [ ] Layout
	- [ ] Model
	- [ ] Texturing
	- [ ] Assets
	- [ ] Change from BPM -> ROY
### Rec Room
- [ ] Bartender #v0_7
	- [x] Design
	- [x] Model
		- [x] Body
		- [x] Head
		- [x] Hair
	- [x] Texturing
	- [x] Rigging @completed(2026-05-17T13:10:45-04:00)
	- [x] Idle Animation
		- [x] ~~Cleaning a glass, passes it to tentacle, which puts it away~~ Lol no, tentacle will just sway
	- [ ] Rewrite dialogue
- [ ] Adonis Enclave #v0_7
	- [ ] Design
	- [ ] Model
	- [ ] Texturing
	- [ ] Idle Animation
	- [ ] Battle Animations
- [ ] Miniboss #v0_7
	- [ ] Model
	- [ ] Texturing
	- [ ] Rigging 
	- [ ] Animation
		- [ ] Channeling
		- [ ] Attack
		- [ ] Getting hit
		- [ ] Battle idle

>[!note] Blue Aligned Modeling
>I have a base template blue-aligned character. To create a new character, all you have to do is:
>1. Duplicate trunk.bak
>2. Convert to mesh
>3. Use proportional editing (random) to push and pull vertices until sufficiently lumpy
>4. When happy with lumpiness, flatten topmost ring of vertices (s > z > 0)
>5. Scale trunk to be more proportional with torso
>6. Combine torso and trunk
>7. Extrude tentacles stumps
>8. Duplicate and scale tentacles and divide into joints
>9. Connect tentacles to stump

>[!hint] Rigging Tentacles and Feet
>- Edit Mode > select base bone > Data pane > Rigify > Samples > Simple Tentacle
>- Edit Mode > Bone pane > Relations menu > Set parent to spine
>- If you cannot see rig, it might be hidden in the face menu for some reason
>- Feet use the Stretchy Chain sample
>- Feet and tentacles will need a lot of loop cuts unfortunately
>- When weight painting the feet, you'll have to zero out vertices on trunk
>	- Top of base should have a weight of 0.2-0.5

>[!note] Optimizing Poly Count
>The feet, tentacles, and trunk need to have lots of faces in order to fully function. It might be smart to consider what actually needs to be animated and what is actually shown.
>
>For instance, I used the bartender character to test the process, but I won't need to animate his feet and his lower body  will be obscured by the counter.
### Continential Breakfast
- [ ] Mischa/Cook
	- [ ] Integrate w/ [[#Story Events and Quests|Quest System]]
	- [ ] Design
	- [ ] Model
	- [ ] Animations
	- [ ] Dialog
- [ ] Breakfast Area Environment
	- [ ] Layout
	- [ ] Model
	- [ ] Texture
	- [ ] Assets
- [ ] Add gate blocking CB from Lobby
### Motel
- [ ] Motel Environment
	- [ ] Layout
	- [ ] Model
	- [ ] Texture
	- [ ] Assets
- [ ] Hidden caves logic puzzle (Lavender puzzle)
	- [ ] Rebalance to use motel layout
	- [ ] Red herring notes
	- [ ] Create notebook object which allows player to leaf thru notes
- [ ] Design monsters and stealth puzzle
- [ ] Priority spell hidden in motel
- [ ] Lavender fight
- [ ] Reward for finishing Lavender puzzle (destroy spell++?)
- [ ] Getting defeated resets your progress
	- Certain areas will reset player when they are defeated (You feel a dark power emanating from all around you)
	- This should be a property of the Chunk
	- I also plan to use Chunks to show which room the player is currently in, it'd be smart to see if these can overlap
### Rampage
- [ ] Rampage 3
	- [x] Design parkour
	- [x] Build parkour
	- [ ] Replace/alter Catalyst puzzle in Rampage1
	- [ ] Add destroy obstacle to Rampage1
### TBD
- [ ] Northern Caves/Portal Complex Excavation
	- [ ] Create and add models for murals
	- [ ] Orange chatlog object created and placed
- [ ] Southern Beach
- [ ] Central hotel
- [ ] Employee breakroom
- [ ] Pool rooms