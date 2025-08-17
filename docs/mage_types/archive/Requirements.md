# Battle (BATT)
1. Show general information about each actor:
2. Show specific information about battle-related topics, when queried by the player.
3. Create detailed battle logs for diagnostic purposes.
4. Allow player to select, deselect, and submit actions.
5. Calculate turn order based on actor's speed and action priority.
6. Calculate and resolve attack/item effects.
7. Apply transmutations and related effects when necessary.
8. Allow attacks to play unique animations.y
9. Remove expired status conditions and stat changes.
10. End battle when player runs away or a team is defeated.
11. Have means to quickly create new attacks both in-game and in-engine.
# Overworld System (OVER)
1. Player should be able to perform simple actions:
	1. Walking/running.
	2. Jumping
	3. Pickup objects and place in inventory.
	4. Open chests.
	5. Drag objects.
2. Each player action should have corresponding animations.
3. The player's current companions should have overworld models that follow the player, without geting in the way.
4. Player should have overworld spells which can be used to get around obstacles.
5. Physics system:
	1.  Should utilize Godot's existing systems.
	2. Should integrate with the chemistry and puzzle block systems.
6. The transmutation mechanic should be included in the overworld, not just in battle:
	1. Certain physics objects should be assigned an elemental type.
	2. Some of these objects should be targetable by the overworld spells.
		1. There should be the option to toggle whether each spell can effect an object.
		2. There should be a visual indicator of which objects can be targeted by which spells.
		3. These visual indicators shouldn't interfere with each other, if a single object can be targetable by multiple spells.
7. Puzzles should be designed using simple building blocks.
8. Puzzles should follow different archetypes that expand on each other.
9. Wild enemies should spawn inside defined areas of the map.
# Character Management and Inventory (CHAR)
1. Opening a menu should pause overworld/game.
2. Player should have ability to save/load games.
3. Player should have access to settings menu.
4. Player should be able to view information about their current party.
5. Player should have a way to distribute stat points when they level up.
6. Player should be able to view and use items in their inventory.
7. Player should be able to manage their current spell movesets.
8. Inventory.
	1. Keep track of items and quantities.
		1. Allow for items to be added/removed from overworld and battle.
		2. Hide items that have 0 quantity.
	2. Items. 
		1. Name.
		2. Items should have flavor text.
		3. Some items can have restrictions.
	3. Regular Items
		1. Some items have BattleItem components and can be used in Battle.
		2. Some can be consumable.
	4. SpellScrolls (SpellBeads)
		1. Gives 1 character access to a spell at a time.
	5. KeyItems.
		1. Name.
		2. Flavor text.
		3. Check if the player has it during story events.
# Settings and Accessibility (Accs)
1. Allow player to reassign keybindings.
2. Add colorblind support.
3. Allow for localizations of text and dialog.
# Story and Content (STRY)
1. Create character bios.
2. Write script for demo area.
3. Write script for main game.
4. Create list of side quests.
5. Write scripts for side quests.
6. Add character dialog.
7. Compile list of story events that impact game state and implement.
8. Design bestiary.
# Polish and Aesthetics (POLI)
1. Create character models and animations.
2. Design and model maps for each section of game.
3. Design and model reusable assets.
