# Misc Notes
- I can't help but feeling that it would be thematically right to give the player some method of permanently altering the environment.
- [x] I really want to find a way to translate the blender clay shader to gdshader code.
- If I add jumping, I can have platforming challenges.
- v0.6 will be the next version I release to my playtesters.
# Upcoming Versions
[[version_naming_scheme]]
## v0.4.x
Puzzle playtest candidate. Players will be able to play through all major puzzles.
- [ ] Write logs to user's system
- [ ] Stasis Dungeon
	- [ ] Chamber 1 bridge puzzle
	- [ ] Mural in Chamber 2
	- [ ] Add puzzles to Chamber 3
- [ ] Enclave stasis backtrack puzzle
- [ ] Plan out beach house sequence and update model
- [ ] See if any puzzles can be ported from previous versions
	- [ ] Lost-forest-style caves => Supply closet
	- [ ] Hidden caves logic puzzle
	- [ ] Original Stasis obstacle
## v0.5.x
Exploration playtest candidate. Player will be able to explore decorated map.
- [ ] Make exploring the map interesting.
	- [ ] Items
	- [ ] Decor
	- [ ] Small puzzles
	- [ ] Add endless stairway to infinite hall
- [ ] Add walls, wall decor, & scene lighting
- [ ] Add colliders and "Wet floor signs" to block access to Purple and Pools
- [ ] When player falls in water, return them to previous stable position
- [ ] Hotel rooms 
	- [ ] Items/mini obstacles
	- [ ] Create door models and animations
	- [ ] On doors player cannot enter, add "Do not disturb" signage
## v0.6.x
Demo MVP prep. Polish features added during previous versions.
- [ ] Content
	- [ ] Rec room battle tutorial
	- [ ] Add backtrack obstacles to beach/etc
- [ ] Battle Animation refactor
	- [ ] Animations handled by BattleGUI
	- [ ] Animations should already be children of gui, just hidden
	- [ ] Attacks access animations using an Id (probably an enum)
- [ ] Wild enemies
- [ ] Opening chests should show player list of contents and allow them to individually select them
## v0.7.x
MVP Demo candidate. Add story and QOL features.
- [ ] Character designs
	- [ ] Blue-aligned
	- [ ] Denim
	- [ ] Player
	- [ ] Lavender
- [ ] Story
	- [ ] Add beach house sequence
	- [ ] Apartment sequence?
- [ ] Accessibility
	- [ ] Colorblind support
	- [ ] Input remapping
	- [ ] Audio/video controls
- [ ] Achievements
- [ ] Start screen
- [x] Allow user to use keyboard to select targets in battle
- [ ] Create conference hall room
- [ ] Create steam page assets
# The List
## Battle (BATT)
- If attack inflicts a phobia or stat change and you want a hyperlink, it might be better to let the Formatters generate it for you.
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
- [x] Status

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


### Settings Menu (sett)
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