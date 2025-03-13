***Current Version***: 0.3.23
# Todo
- [x] Change battle gui to support 3D models instead of sprites.
- [x] Refactor menu screen management.
- [ ] Add demo content.
	- [ ] Demo Item list created.
	- [ ] Demo attack list created.
	- [ ] Demo beastiary created.
- [ ] Add textures and animations to demo.
- [x] Save/load system.
- [ ] Color blind accessibility.
	- [x] Backend architecture.
	- [ ] Preset options. 
- [ ] Input remapping.
- [x] Grabbable dynamics.
- Geyser dynamics.
	- [x] Geyser not lifting player.
	- [x] When two geysers are in opposition and one is turned off, the other will not push on objects inside of it.
- [ ] Achievements.
- [x] Cutscenes
- [ ] Have draggables snap player to grid.
## Known Bugs
- [x] Actor formatter is broken (if attack is null, it fails).
- [ ] Message displayed when actor is inflicted with phobia just says "Blank".
	- Cannot replicate?
- [ ] Player normal map is inverted.
	- Cannot replicate?
- [x] Shadow on blob texture.
	- Try known workaround (Worked!).
- [x] Laser bugs:
	- [x] If laser doubles back on itself, mirrors immediately glitch out.
# Upcoming Versions
[[version_naming_scheme]]
## v0.3.x
Demo main track implemented. Player can play through the main story of the demo, but not necessarily any of the extra content.

**STRY.x**
- Battle actors for each boss created (x3).
	- [x] Boss 1
	- [ ] Boss 2
	- [ ] Final Boss
- Main puzzles designed and implemented (x3).
	- [x] Stasis
	- [x] Catalyst
	- [ ] Final
- [ ] Demo partner tutorial dialog written.
- [ ] Blocking and non-blocking dialog triggers implemented.
	- [x] Blocking.
	- [ ] Non-blocking.
- [x] Cutscenes.
**OVER.spel**
- Overworld spells implemented:
	- [x] Stasis
	- [x] Catalyst
- [x] Graphic showing which overworld spell is currently selected.
**OVER.wild**
- [x] Wild enemies implemented.
- [ ] Simple wild enemy behavior.
**OVER.publ**
- [x] Light up indicator wire created.
**CHAR.save**
- [x] Save/load architecture implemented.
**STRY.trig**
- [x] Allow StoryActors to share AnimationPlayers.
- [x] Allow StoryTriggers/StoryActors to play animations asynchronously.
## v0.4.x
Demo MVP. Player can visit every area of the demo and experience the major features.

**STRY.x**
- [ ] Purposes for Forest, Tidepools, and Riverfront determined.
- [ ] Whiteboxed mockup of map. Unimplemented areas can be blocked off.
- [ ] Deep caves puzzle implemented and tested.
- [ ] Destroy time trial designed, implemented, and tested.
**OVER.chco**
- [x] Player can open chests and obtain items.
**OVER.plco**
- [ ] Player companions follow player.
**OVER.spel**
- [ ] Destroy spell implemented.
## v0.5.x+
Demo playtest candidate.

**OVER.clay**
- [ ] Visual indicator on MagiClay objects.

**POLI.achi**
- [ ] Achievements.
# The List
## Battle (BATT)
### Actor Info (ainf)
**Show information about each actor:**
- [x] Name, Hp.
- [x] Current Element.
- [ ] Elemental Bias.
- [x] Status effects.
	- [ ] Use 3d model pins instead of 2d sprites.
- [x] Stat changes.
- [ ] Use 3d models instead of 2d sprites for characters.

### General Info (ginf)
**Show information about the following, when queried by player:**
- [ ] Attack info.
- [ ] Item info.
- [ ] Battle Actor info.
- [ ] Status conditions.
- [ ] Debug info.

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

### Transmutations (tran)
**Apply transmutations and related effects when necessary.**
- [x] (Primary | Secondary) + Attack
- [x] Primary + Secondary
- [x] Apply side effects.

>[!question] 
>There should be some way for the player to change their secondary Blank typing to another element.
>Maybe if their secondary typing is Blank, it will change to match the typing of the move they just used?

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

### Puzzle Blocks (publ)
**Puzzles should be designed using simple building blocks.**
- [ ] Light up wire should show how different puzzle blocks are connected and whether they are active.

### Puzzle Archetype (puar)
**Puzzles should follow different archetypes that expand on each other.**

### Wild Enemies (wild)
**Wild enemies should spawn inside defined areas of the map.**
- [ ] Wild enemies should have overworld models.
	- [ ] These models should show some information about the enemies involved (e.g. their starting typing, difficulty).
	- [ ] When the player collides with these models, a battle should commence.
- [x] Spawner fields should be used to control what can spawn and where.
	- [x] A Spawner should be given a list of BattleActors, which act as the base template for each enemy that can spawn.
	- [x] When an enemy is instantiated, its stats should be subject to some amount of variance.
- [ ] Wild enemies should be physics objects.
- [ ] Different enemies should have different overworld behavior.
	- [ ] Chasing player.
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

### Party Info (pinf)
**Player should be able to view information about their current party.**
- [x] Name.
- [x] Current primary and secondary typing.
- [x] Bias, if any.
- [ ] Level and experience.

### Stat Management (stat)
**Player should have a way to distribute stat points when they level up.**

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
	- [ ] Ensure character meets item requirements.
- [ ] Remove spell from moveset.
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
- [ ] Allow StoryActors to share AnimationPlayers.
- [ ] Allow StoryActor to trigger animations directly.

### Dialog (dial)
**Display dialog when player talks to character.**
- Allow characters to vary dialog based on :
	- Number of times player has talked to them.
	- Story events that have/have not happened.
	- Answers player has previously given them.
	- Items in player's inventory.
	- If the player has defeated them in battle.
### Story Events (even)
- Play cutscene.
- Add/remove items from player's inventory.
- Set/check story variables.
- Add/remove companion.

_StoryEvent_
- Is triggered by an external factor, usually an action the player has taken.
- Changes something about the game's state.
	- This should probably be a global variable any other actor can check.
	- This should probably interface with the variables used in the Dialogue nodes addon.
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
- [ ] Have achievements sync with steam library.