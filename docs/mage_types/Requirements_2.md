# Battle (BATT)
1. [x] Battle UI(@11567109872507702583)
	1. [x] Support battles w/ variable numbers of combatants.(@3572361621919980806)
	2. [x] Display info about each actor.(@6346666021234991632)
		1. [x] Name, Hp, Current element.(@2853532521296875199)
		2. [x] Status effects.(@16487342674427999367)
		3. [x] Stat Changes.(@4990075521729990646)
	3. [x] Allow player to select/deselect actions for each of their characters.(@16485887229983581996)
		1. [x] Player selects an action for each actor, moving from right to left.(@13893437085453142112)
		2. [x] Once an action is selected, UI automatically moves to next actor.(@18117927818103411362)
		3. [x] The player has the option to select different actions for previous actors.(@2810703269950299967)
			1. [x] This should not cause the game to forget any other selected actions (e.g. Alice chooses attack, then Bob chooses attack. If player goes back to change Alices action, this should not deselect Bobs action).(@1122450439457916221)
		4. [x] View detailed info about things in battle.(@14903634935960503086)
			1. [x] Show info about attacks when selected by player.(@6555783482266250750)
			2. [x] Show info about items when selected by player.(@16833176933064244463)
			3. [x] Show info about actors controlled by player.(@6469789126453551586)
			4. [x] Show info about status conditions.(@5075124357433597779)
			5. [x] Show debug info.(@8639032827776747037)
				1. [x] Show info about stat changes (e.g. exact math).(@8046598774954698199)
				2. [x] Show info about opponent's battle actors.(@6669910798575405418)
			6. [x] Enable verbose logging for diagnostic purposes.(@5854952463303537748)
		2. [x] Elemental System.(@16757349436550575563)
			1. [x] Attack + Primary & Attack + Secondary transmutations.(@16147554132515372797)
			2. [x] Primary + Secondary transmutations.(@17620284291255335798)
			3. [x] Apply related side effects.(@14301256547258612795)
			4. [x] Modify damage based on resistances/weaknesses.(@15374561585134094899)
		3. [x] Attack effects.(@7029671350467911502)
			1. [x] Play animations.(@13780736768744166406)
				1. [x] Support both particle effects and other types of *animations*.(@10180930956102393617)
			2. [x] Calculate and apply damage based on stats and resistances.(@9527863929149726693)
			3. [x] Apply status effects, if applicable.(@12596813966548797135)
			4. [x] Allow attacks to feature unique mechanics.(@12620800385948024038)
				5. [x] Allow non-unique mechanics to be easily shared between attacks.(@16971263064959138765)
			5. [x] Incur affinity/quantity costs on player.(@8018470864708076384)
		4. [x] Status effects.(@6492301569768904463)
			1. [x] Calculate and apply effects at end of turn.(@6508698152141963812)
			2. [x] Remove expired status effects.(@1745469183734065153)
		5. Item effects/usage.(@9228490801500514809)
			1. [x] Play animation.(@5801080165827534273)
			2. [x] Apply effects to target(s).(@10244738836906453254)
			3. Remove from inventory.(@5042936279717307206)
				1. Prevent player from double spending an item.
		6. [x] Attack Builder.(@3922389057398677443)
			1. [x] Select required attributes: Name, Element, Priority, Range, Target, Cost. (@16784333745737265948)
			2. [x] Fill out optional details section.
			3. [x] The following attributes will need to be manually filled out or give the user access to the filesystem: Animation, AttackEffects.
			4. [x] Allow the user to create 1+ Effects.
				1. [x] Chance.
				2. [x] Target.
				3. [x] AttackEffect.
		7. Customizable opponent ai.(@763817318648242929)
			1. Simple difficulty controls.(@3535535316469217606)
			2. Allow for different NPCs to use different strategies.(@611690462904795703)
# Overworld (OVER)
1. Character controller.
	1. Character should feel nice to control.
	2. Should be able to perform a range of actions:
		1. Walking
		2. Running
		3. Jumping
		4. Pick up objects
		5. Drag objects
		6. Open chests
	4. Each action should have a corresponding animation.
	5. The player's companions should have overworld models which follow the player, without getting in the way.
2. Overworld spells:
	1. Architecture should support addition of new spells.
		1. Abstract common functionality.
			1. Aiming/Targeting.
			2. Instantiating projectile.
			3. Selecting an element based on environment/player input/etc.
		2. New spells should be able to be integrated in 1-2 steps.
3. Physics system:
	1.  Should utilize Godot's existing systems.
	2. Should integrate with the chemistry and puzzle block systems.
4. Chemistry system (MagiClay):
	1. Certain physics objects should be assigned an elemental type.
	2. Some of these objects should be targetable by the overworld spells.
		1. There should be the option to toggle whether each spell can effect an object.
		2. There should be a visual indicator of which objects can be targeted by which spells.
		3. These visual indicators shouldn't interfere with each other, if a single object can be targetable by multiple spells.
5. Puzzle design (PuzzleBlocks).
	1. It would be helpful to have specific puzzle archetypes, e.g. the laser system already implemented. This would make teaching the player about the system easier.
	2. Even with separate archetypes, all puzzle blocks should logically interact with other Blocks/MagiClay/physics objects.
6. Wild enemies.
	1. Wild enemies should have overworld models.
		1. These models should show some information about the enemies involved (e.g. their starting typing, difficulty).
		2. When the player collides with these models, a battle should commence.
	2. Spawner fields should be used to control what can spawn and where.
		1. A Spawner should be given a list of BattleActors, which act as the base template for each enemy that can spawn.
		2. When an enemy is instantiated, its stats should be subject to some amount of variance.
	3. Wild enemies should be physics objects.
	4. Different enemies should have different overworld behavior.
		1. Chasing player.
		2. Charging at player.
		3. Fleeing from player.
		4. Attacking other wild monsters.
		5. Not attacking the player unless they interact, instead of on collision.
	5. Different enemies should have different behavior in battle.
# Story (STRY)
# Character Management and Inventory (CHAR)
1. Pause menus.
	1. Pause overworld when menus are open.
	2. Manage multiple different types of menus.
2. View information about each character.
	1. Name.
	2. Current primary and secondary typing.
	3. Bias, if any.
	4. Level and experience.
3. Stats.
	1. View stats for player and companions.
	2. Assign/reallocate stat points.
4. Moveset.
	1. Teach character a new spell.
		1. Require player to have proper SpellScroll available.
	2. Remove spell from character.
	3. Reorder spells in moveset.
	4. Replace spell.
5. Inventory.
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
2. Colorblind mode.
# Polish and Aesthetics (POLI)