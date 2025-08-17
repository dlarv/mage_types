# Battle System
## Adding an Attack
1. Create new Attack resource.
## Adding a new Status Effect
## Adding a new Battle Item
## Adding a new Opponent Controller

# Characters
## Scene Setup
1. Add DialogueBox to scene.
2. Add VendorMenu to scene.
3. Create new dialog tree resource and add it to `DialogBox.data`.
4. Connect `Player` signals to `OverworldConnector`.
## Creating an NPC
1. Add NPC to scene.
2. Add CollisionShape3D, MeshInstance3D, etc.
3. Add applicable actors.
### Add a StoryActor
1. [[#Creating an NPC|Create NPC]].
2. Add StoryActor.
3. Add one or more new dialog tree to scene's dialog tree resource.
4. Set `StoryActor.dialog_ids` to a list of the ids created during step 3.
5. Set `StoryActor.current_id` to the index of whichever id to use first.
### Creating a Wild Enemy
1. [[#Creating an NPC|Create NPC]].
2. Add NPC to "wild_enemies" group. 
	1. If the player collides with 2 enemies at once, or the original enemy isn't removed from scene immediately, this will prevent it from immediately starting a new battle.
3. Add EnemyActor.
	1. Fill out `team` w/ BattleActors.
	2. Add an `OpponentController`.
### Creating an Aggressive StoryActor
>[!note]
>This doesn't entail a 'mean' StoryActor, just that one of its dialog branches ends w/ the "battle_started" signal.
1. [[#Creating an NPC|Create NPC]].
2. Add EnemyActor
	1. Fill out `team` w/ BattleActors.
	2. Add an `OpponentController`.
3. Add StoryActor.
### Creating a Vendor
1. [[#Creating an NPC|Create NPC]].
2. Add list of items, either manually or using the 'Add Item' field in the inspector.
	1. Dragging an item will automatically create the associated wrapper class.
	2. You just need to fill out the `cost` field.
3. \*If Vendor has no StoryActor, the following should be added to the scene's dialog tree:
	1. Start Node w/ ID="VENDOR_MAIN".
	2. Dialogue Node w/ generic text.
	3. Signal Node w/ signalname="menu_opened".
4. If Vendor has a StoryActor, make sure one of its dialog branches ends w/ a "menu_opened" signal.

\*All solo(non-StoryActor) VendorActors in this scene will use this generic dialog.
# Overworld
I think it would make the most sense to take a top-down approach to level design. This would involve designing key story locations/setpieces/dungeons/puzzles/etc, then figuring out how best to connect them.
## Demo
- Showcase systems and mechanics in the game.
- Largely overlap with areas in actual game; minimize redundant work.
	- It could make sense to place the demo inside the beginning areas of the Blue region.
## Region Objectives/Themes
- Blue
	- Transmutation system.
	- Offensive/defensive.
		- Affinity.
		- Side-effects.
	- NARRATIVE: Setup story.
- Purple
	- Weaknesses/Resistances.
- Magenta
	- Creepy backroom carnival.
	- Circus?
- Red
- Orange
	- Transmutation puzzles?
- Yellow
	- Physics puzzles?
- Green
	- NARRATIVE: Rising action.
- Island
	- NARRATIVE: Climax?
- Cyan
	- Finale

All Regions should have both narrative elements and unique mechanics. These factors should be balanced, so that areas with less narrative weight have unique mechanics and vice versa.
## Overworld Mechanic
Over the creation of this game, I have found myself struggling to come up with a solid overworld mechanic. However, this entire time I have been missing the obvious idea right in front of me. From almost the beginning, I decided to give this game a claymation aesthetic. This game should give the player the ability to manipulate their environment. Not to the degree of something like Minecraft, but something like the Sand Wand from LOZ: Spirit Tracks.  

The Sand Wand allows the player to raise a pillar of sand (when standing on sandy terrain). I like the idea of giving the player LOZ-esque items that let them manipulate select areas of the environment.

For distantly related discussion of repeated overworld mechanics:  [[puzzle_archetypes]].

Ideas:
1. [x] Stasis
2. [x] Raising platforms
3. [x] Creating bridges
4. [ ] Tunneling 
	1. Moving through walls.
	2. "Teleport" between 2 different spots.
5. [ ] Jumping/Vertical boost
6. [x] Catalyst (Overworld transmutation spell).
7. [ ] Breaking Obstacles.
## Overworld Transmutation Mechanic
I think it would serve the game to have some way to interact with the transmutation system while in the overworld. 

>[!question] Changes/Clarifications of Lore 
>Elementally speaking, what is the relationship between the region and its element? 
>
>Like non-Blue elements can exist in Blue without immediately being transmuted. And parts of people's bodies can be composed of different elements, which isn't necessarily related to their alignment.
>
>My current model/understanding is that the region of Blue exerts a sort of Blue pressure on anything inside of it. Does this cause them to transmute into Blue or does it cause reactions with Blue? So either:
>- Red + Blue-region => Blue
>- Red + Blue-region => Magenta
>Or should this pressure just make it so that non-Blue elements transmute easier and vice versa?
>
>`I think the best idea is that elements of all types can spawn in any region, but there is a pressure causing foreign elements to transmute easier and non-foreign elements to resist transmutation. Large foreign objects have a sort of chemical inertia, which prevents them from transmuting unless a catalytic force is introduced. Finally, some large objects can have their own alignment/bias, causing them to revert to a set element given enough time.`
>
> So outside of temples, foreign objects will be naturally occuring, but won't respawn if destroyed by the player. Inside of temples, foreign objects are introduced and have a bias, which allows the puzzles to reset themselves.
## The Main Quest 
To help survivors adjust to their new life on Forlorn, the inhabitants have devised the "Quest." The reasoning given for this is a sort of innoculation, helping stage off alignment before the newcomer has a chance to understand the commitment. Now, at a glance this challenge might seem overly dangerous. Surely, the additional risk of injury would increase the rate of alignment? However, the locals assure me that the minor scrapes and bruises incurred by the Questees have the inverse effect. The relevant statistics seem to corroborate these assertions, provided the accurate reporting of such a fact, of course. In my own observations, the residents of Forlorn appear much hardier than their species of origin. Even after a mere week, residents appeared twice as durable as their non-Forlornian counterparts, which ranged up to 5 times given a year.

This "Quest" takes the form of 7 dungeons. One might be inclined to think this number should be 8 (one for each region). The source of this disparity is the Sunset Temple: a partnership between Orange and Yellow. The details of each temple challenge is left to the discretion of the Region's Quest Commitee.
## Dungeons
- Blue Temple
	- Water, Astral/Psychic.
	- Stasis and dissonance.
- Purple Temple
	- Astral/Psychic, Darkness.
	- Battle/damage.
	- Strike attack type.
- Magenta Temple
	- Fairy, Whimsy, Glitter.
- Red Temple
	- Blood, Plant.
- Sunset Temple (Orange & Yellow)
	- Plastic, Fire (Orange).
	- Air, Light (Yellow).
	- Transmutation puzzles.
	- Physics puzzles.
- Jungle Temple (Green)
	- Radiation, Poison.
	- Hostile and aggressive.
	- Battle gauntlet.
- Mine/Abandoned Temple (Green)
	- Energy.
- Cyan Temple
	- Ice, Steel.

Temples be a showcase of an element's unique features and its region's culture. These temples should have a combination of puzzles and battles.
### Blue Temple
- Astral/Psychic, Water
- Stasis and dissonance.
- Transmutation system.
- Offensive/defensive.
	- Affinity.
	- Side-effects.

Blue-aligned people have high ambitions, but low motivation. It follows that they should start large projects, but be unable to properly finish them. Blue's temple should have one large, impressive chamber - surrounded by smaller, more spartan rooms. It should be implied that they received help from Cyan to finish this central chamber.

The main *mechanic* should relate to stasis(1). The player will be given an object that allows them to apply an AOE stasis spell. When applied, clay objects cannot be transmuted or move.
### Purple Temple
- Astral/Psychic, Darkness.
- Hostile, aggressive.
- Weaknesses and resistances.
- Fear, flinching.

The majority of the Purple region is subterranean, embedded in the cliffs north of Blue. Purple is the second most aggressive element, with Purple-aligned people being some of the most feared and unsettling. Purple's Temple should be small, cramped, and dark, with an emphasis on battling.

It could be interesting if the puzzles were less focused on allowing the player to physically progress, instead opting to make the challenge easier (i.e. the chandelier from Hollow Knight).
### Magenta Temple
- Creepy backroom carnival.
- Circus?
- Fairy, Whimsy, Glitter.
- Healing.

Most of Magenta has been developed into a large, amusement park. Their segment of the quest is used as a sort of teaser, requiring the player to collect (six?) stamps from different attractions.

The player should be able to find the first 5 (n-1) areas rather easily. When the quest handler is approached about this, they will say something about "Oh, that must have been a misprint. Here's an updated version." Magenta architects have to constantly battle against their region getting reclaimed by the wild. Whenever this battle is lost, the section is quarantined off. This was the fate of the previous 6th attraction.

The player should have the ability to find the old 6th attraction (and potentially more of these backrooms).

This won't introduce any new mechanics/overworld spells. Each stamp will act as a test for mechanics already introduced:
- Stasis Spell
- Transmutation
- Weaknesses & Resistances
- Status Effects
### Red Temple
- Blood, Plant.
	- Creepy garden.
- Sacrifice, ritual.

Red should be large and imposing. It should have somewhat creepy vibes, but still be family friendly, so no gore/etc (the blood is more of an implied/author-only guideline).

This temple would introduce a vine growing(2,3) *mechanic*, which would give the player horizonal and vertical mobility. 
### Sunset Temple
- Plastic, Fire (Orange).
- Air, Light (Yellow).
- Transmutation puzzles.
- Physics puzzles.

The joint effort of Yellow and Orange's temple is born from both of their practical natures. Yellow would rather focus on their logistic networks and Orange prefers to work on their experiments.

This temple should be impressive and polished, but simple. The player will likely have a chance to explore a chunk of the Orange region, allowing this location to build off of any concepts introduced there.

This temple would introduce the catalyst(6) spell (*mechanic*). This would allow the player to transmute objects in the overworld.

>[!tip]
>This would have some serious backtracking potential, allowing the player to open up previously blocked off avenues.
### Jungle Challenge
- Jungle Temple (Green)
	- Radiation, Poison.
	- Hostile and aggressive.
	- Battle gauntlet.
Born from the resentment felt by Green towards the other regions, this challenge is less temple and more boss rush. The real tragedy of the situation is that historically, Green was the most into the Quest. This fact is shown via the contrast between the Jungle and Mine temples.

Mechanic Ideas:
- No new mechanic.
### Abandoned Temple
- Mine/Abandoned Temple (Green)
	- Energy.
As mentioned above, the Mine Temple was built at the apex of Green's passion for the Quest. As such, it should likely be the biggest temple of the lot.

This temple is optional, though it should be on the main path.

Mechanic Ideas:
- Tunneling (4) 
### Cyan Temple
- Ice, Steel.
- Blocking.

Mechanic Ideas:
- No new mechanic (Since this is the last temple, it probably wouldn't make much sense to introduce another mechanic. It should just expand on all the previous ones).
