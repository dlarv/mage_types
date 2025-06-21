>[!note]
>This document is primarily intended to show the room-by-room breakdowns of each region.
# Blue
Blue consists of 3 sub-regions:
- The hotel
	- Many of the enclaves exisit inside of the first section, typically inside of the actual hotel rooms.
	- The hotel should have 3 levels, with the 2nd and 3rd being hidden behind the caves/pools.
- The pool rooms
	- The pool rooms are intended to be smaller sections, moreso paying homage to this liminal spaces trope.
- The caves
	- The caves seem almost like they were once hidden away, accessible only through holes smashed in the walls.

Each of these sections will weave through each other.

>[!idea] Hotel Amenities
>The could be an enclave inside of the workout room. This could be a good place to have some kind of battle tutorial.
## Beach
- Player will spawn on lighthouse pier.
- Player will enter beach house, where they will meet Alice and the Caretaker.
### Meeting Partner and the Caretaker
- Intro Denim.
- Determine Denim's fated bias.
	- Denim asks the player several questions. These will allow the player to roleplay, but serve the hidden purpose of determining her fate.
- Intro world.
- Give player their first goal (reaching the community center).
	- Player given option to choose their true motivation (why are they searching for the diner?)
		- Seeking answers.
		- Pancakes real good.
		
Script: [[Beach House Intro]]
## Hotel
- Battle Tutorial: Inside Rec Room.
- First boss inside hall1, forcing player to backtrack to Rec Room if they don't understand how to fight.
- There should be some items hidden inside of simple hotel rooms.
	- Some rooms should look normal, but some should be bizarre.
- I'll take the hidden cave puzzle (Lavender's puzzle) and put it inside of a middle section of the hotel.
- World geometry will get weirder the further the player is from the main path.
	- I.e. infinite hallway, path to Lavender's puzzle.
### Rec Room
- Battle Tutorial
### Hotel Enclave
- Player will be expected to backtrack here once they get Stasis.
## Caves
### Ziggurat 
- Inside the Grand Enclave Ziggurat, there are 8 giant pillars the player can use to ascend to the surface. However, the first one has collapsed, revealing a hidden side path. The player must venture down this side route and loop back in order to ascend.
	- The player will use a geyser to scale the side of the giant pillar. Therefore, they should be introduced down the side paths.
### Stasis Dungeon
- I want this to be formatted sort of like a Zelda dungeon. Player will adventure halfway through the dungeon, battle a miniboss, obtain the Catalyst spell, then loop back unlocking new paths in sections they've already been.
#### Central Chamber (Starting Config)
- When the player first enters dungeon, it will be in a limited version, with three layers separated by three concentric walls.
- The player will be presented with three simple obstacles in sequence. These will mostly be to introduce the player to the lasers, mirrors, rails, and lenses, as well as the hidden receivers.
	- As the player solves these obstacles, the walls will come down, slowly opening up more of the room.
- Once all walls have been dropped, player will be presented with 7 doors (8 including the one they entered from). 6 of these doors will be locked.
- Heading down the other unlocked path will take them into the Mural Room.
#### Mural Room
The player will be able to enter this section without too much trouble. At the end, they will find the boss and Stasis. Upon picking up the spell, a trap will trigger, locking the player inside. The player will be presented with 3 riddles to solve.
- 4 Lasers will be arrayed aroudn the edges of the room. Each one hits a hidden receiver.
	- These will be Red, Green, Blue, and Yellow.
- The player must decipher the riddles to determine which lasers to turn off.
- Correctly solving one configuration will activate receivers on rails, automatically advancing the puzzle.
- Solving all 3 configs will open the gate, allowing the player to return to chamber 1.

I'd like the riddles to have a deeper connection to the lore, possibly to the Old Guard. It'd be cool if they told a story. The characters should be named after colors or share the first letter of their names with colors. Each of the visible 3 walls will have a 'mural' on it. The player must use stasis on the lasers whose characters are not included in the mural.
- RGB, !Y
- RG, !BY
- Y !RGB
#### Central Chamber (Main Config)
- Once the player finished up inside the mural room, they will reenter the Central Chamber.
- Triggering the trap will also cause the Central Chamber to switch to the main configuration.
- All doors, except for the West one, will be unlocked.
- There will be a large puzzle, featuring: 8 emitters, 8 hidden receivers, and 24 mirrors/lenses.
	- To solve this puzzle, the player must use stasis on the correct *3* mirrors/lenses. There are also *3* lenses connected to rails which must be moved out of the way.
	- Solving this central puzzle will unlock the West door, allowing the player to escape the puzzle.
	- This puzzle will be impossible to solve without using brute force. To solve it, the player must venture down the side paths to find hints telling them what colors the hidden receivers will be.
- Heading down the NW, NE, SW, & SE doors will take the player to side puzzles.
	- Each side path should have an elemental theme
- At the end of each side path will be a chest containing some cool items. Each chest will also contain a key, which can be used in the East room.
	- Unlike the other doors, the East door will take the player into a single room. Inside this room will be a small door with 4 keyholes.
	- Using the keys the player has found throughout the side paths will grant them access to the vault.
	- Ideas for vaults content: 
		- Merchant who sells all items
		- Powerful equipment (PreventDefeat, Reactor Shard)

>[!error] Puzzles 
> I'm not vibing with my ability to design interesting puzzles. I feel like I'm likely just designing busy work for the player.
> 
> Maybe I should focus on making the puzzles teach specific concepts first and be puzzles second.

Each of the four hallways will have an elemental theme based on 4 of the 5 elements included in the limited version of the matchup menu (Blue, Magenta, Red, Orange). The East wing will be based off of Purple, but this won't be explicitly stated (b/c Purple is sneaky). The East wing will contain the final boss.
- Challenges should still incorporate the Stasis spell.
	- Each wing should have its own mechanic that interfaces with the spell.
- Challenges should be a mix of puzzles, combat, and platforming.

[[demo_script]]
#### NE Chambers (Blue)
- This section should focus mostly on puzzles.
	- It could focus on some intersection between Stasis and water. 
	- Use of geysers?
This section was the coolant for the machine and is located mostly underneath the other wings. It features a few puzzles where the player has to manipulate geysers using stasis and a few platforming challenges to get around water obstacles.
#### SE Chambers (Magenta)
This section takes place on the control panel, which is built on the scale of massive beings. The control panel mentioned in the earlier chatlogs is actually a non-functional replica created by beings trying to manipulate the machine before realizing it to be impossible.
#### SW Chambers (Red)
This section grew around the main power conduit. Due to the abundance of water and energy, this area has flourished, being home to multiple different species of flora and fauna.
#### NW Chambers (Orange)
This section is actually inside of the power conduit found in the Red section. The two side chambers sticking out from Room3 will take the player outside of the inner sheath. They'll still be in the conduit, but it'll be a bit more obvious (mb there will be a section with a large tear that can be seen from Red).
## The Ascent
After solving the stasis dungeon, the player reenters the ziggurat, this time with access to the top of the pillars. The player will follow a counter-clockwise path to the surface. There are 7 pillars, I don't know whether each one should have some form of challenge, or just a few.
****