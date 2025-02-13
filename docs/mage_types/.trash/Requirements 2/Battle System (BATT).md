1. Show information about each actor:
	1. Name.
	2. Hp.
	3. Current Element.
	4. Elemental Bias.
	5. Status effects.
	6. Stat changes.
2. Show information about the following, when queried by player:
	1. Attack info.
	2. Item info.
	3. Battle Actor info.
	4. Status conditions.
	5. Debug info.
3. Create detailed battle logs for diagnostic purposes.
4. Allow player to select, deselect, and submit actions.
5. Calculate turn order based on actor's speed and action priority.
6. Calculate and resolve attack/item effects.
7. Apply transmutations and related effects when necessary.
8. Allow attacks to play unique animations.
9. End battle when player runs away or a team is defeated.
# Elemental System
10.  Attack + Primary & Attack + Secondary transmutations.
11.  Primary + Secondary transmutations.
12.  Apply related side effects.
# Battle Actions
# Attack Builder
# Opponent AI
13.  Attack effects.(@7029671350467911502)
	1.  Play animations.(@13780736768744166406)
		1.  Support both particle effects and other types of *animations*.(@10180930956102393617)
	2.  Calculate and apply damage based on stats and resistances.(@9527863929149726693)
	3.  Apply status effects, if applicable.(@12596813966548797135)
	4.  Allow attacks to feature unique mechanics.(@12620800385948024038)
		1.  Allow non-unique mechanics to be easily shared between attacks.(@16971263064959138765)
	5.  Incur affinity/quantity costs on player.(@8018470864708076384)
14.  Status effects.(@6492301569768904463)
	6.  Calculate and apply effects at end of turn.(@6508698152141963812)
	7.  Remove expired status effects.(@1745469183734065153)
15. Item effects/usage.(@9228490801500514809)
	1.  Play animation.(@5801080165827534273)
	2.  Apply effects to target(s).(@10244738836906453254)
	3. Remove from inventory.(@5042936279717307206)
		1. Prevent player from double spending an item.
16.  Attack Builder.(@3922389057398677443)
	4.  Select required attributes: Name, Element, Priority, Range, Target, Cost. (@16784333745737265948)
	5.  Fill out optional details section.
	6.  The following attributes will need to be manually filled out or give the user access to the filesystem: Animation, AttackEffects.
	7.  Allow the user to create 1+ Effects.
		2.  Chance.
		3.  Target.
		4.  AttackEffect.
17. Customizable opponent ai.(@763817318648242929)
	1. Simple difficulty controls.(@3535535316469217606)
	2. Allow for different NPCs to use different strategies.(@611690462904795703