***Current Version***: 0.3.0
# Todo
- [ ] Refactor menu screen management to use stacks.
- [ ] Add demo content.
	- [ ] Demo Item list created.
	- [ ] Demo attack list created.
	- [ ] Demo beastiary created.
- [ ] Add textures and animations to demo.
- [ ] Change battle gui to support 3D models instead of sprites.
## Known Bugs
- [ ] Actor formatter is broken (if attack is null, it fails).
- [ ] Message displayed when actor is inflicted with phobia just says "Blank".
- [ ] Player normal map is inverted.
# Upcoming Versions
[[version_naming_scheme]]
## v0.3.0
Demo main track implemented. Player can play through the main story of the demo, but not necessarily any of the extra content.

**STRY.x**
- [ ] Battle actors for each boss created (x3).
- [ ] Main puzzles designed, implemented, and tested (x3).
- [ ] Demo partner tutorial dialog written.
- [ ] Blocking and non-blocking dialog triggers implemented.
**OVER.spel**
- Overworld spells implemented:
	- [x] Stasis
	- [x] Catalyst
- [ ] Graphic showing which overworld spell is currently selected.
**OVER.wild**
- [ ] Wild enemies implemented.
**OVER.publ**
- [ ] Light up indicator wire created.
## v0.4.0
Demo MVP. Player can visit every area of the demo and experience the major features.

**STRY.x**
- [ ] Purposes for Forest, Tidepools, and Riverfront determined.
- [ ] Whiteboxed mockup of map. Unimplemented areas can be blocked off.
- [ ] Deep caves puzzle implemented and tested.
- [ ] Destroy time trial designed, implemented, and tested.
**OVER.chco**
- [ ] Player can open chests and obtain items.
**OVER.plco**
- [ ] Player companions follow player.
**OVER.spel**
- [ ] Destroy spell implemented.
## v0.5.0+
Demo playtest candidate.

**OVER.clay**
- [ ] Visual indicator on MagiClay objects.
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
- [ ] Select required attributes: Name, Element, Priority, Range, Target, Cost. 
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
- [ ] Open chests.
- [x] Drag objects.
- [ ] Each player action should have corresponding animations.

### Player Companions (plco)
**The player's current companions should have overworld models that follow the player, without geting in the way.**
- [ ] Status

### Overworld Spells (spel)
**Player should have overworld spells which can be used to get around obstacles.**
**Physics system**
- [x] Should utilize Godot's existing systems.
- [x] Should integrate with the chemistry and puzzle block systems.
- [x] Allow player to select up to 2 overworld spells to use at a time.
	- [ ] A graphic should be used to show which 2 overworld spells are currently selected.
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
- [ ] Spawner fields should be used to control what can spawn and where.
	- [ ] A Spawner should be given a list of BattleActors, which act as the base template for each enemy that can spawn.
	- [ ] When an enemy is instantiated, its stats should be subject to some amount of variance.
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

### Settings Menu (sett)
**Player should have access to settings menu.**

### Party Info (pinf)
**Player should be able to view information about their current party.**
- [ ] Name.
- [ ] Current primary and secondary typing.
- [ ] Bias, if any.
- [ ] Level and experience.

### Stat Management (stat)
**Player should have a way to distribute stat points when they level up.**

### Item Management (iman)
**Player should be able to view and use items in their inventory.**

### Spell Management (sman)
**Player should be able to manage their current spell movesets.**
- [ ] Teach character a new spell.
	- [ ]  Require player to have proper SpellScroll available.
- [ ] Remove spell from moveset.
- [ ] Reorder spells in moveset.
- [ ] Replace spell.
## Settings and Accessibility (ACCS)
### Keybindings (keyb)
**Allow player to reassign keybindings.**
### Colorblindness (colb)
- [ ] Allow RGB values for each Element to be changed.
- [ ] Provide RGB presets for colorblind players.
### Localizations (locl)
**Allow for localizations of text and dialog.**
## Story and Content (STRY)
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