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
### Supply Closet
This is where I test and demo all puzzle blocks. In the back of this section there will be a door to the Backrooms, which are a Lost Forest style puzzle where the player must use their knowledge of Offensive/Defensive elements to navigate it.
## Caves
### Ziggurat 
- Inside the Grand Enclave Ziggurat, there are 8 giant pillars the player can use to ascend to the surface. However, the first one has collapsed, revealing a hidden side path. The player must venture down this side route and loop back in order to ascend.
	- The player will use a geyser to scale the side of the giant pillar. Therefore, they should be introduced down the side paths.
## Stasis Dungeon
- I want this to be formatted sort of like a Zelda dungeon. Player will adventure halfway through the dungeon, battle a miniboss, obtain the Catalyst spell, then loop back unlocking new paths in sections they've already been.
- This area was once the Godling Portal Complex. In the actual game it will have been taken offline, to prevent destroying the world. But I think it could be funny if in the demo the machine is operable, with the player slowly turning it on.
	- At the apex the player will have the option to activate the machine, destroying the world.
	- A little further down the track will be the Orange chatlogs discussing why turning on the machine is a bad idea.
- As the player activates the various components, giant mechanisms will begin moving in the central chamber.
	- These could reveal the components to the central puzzle.
### Central Chamber (Starting Config)
- When the player first enters dungeon, it will be in a limited version, with three layers separated by three concentric walls.
- The player will be presented with three simple obstacles in sequence. This is primarily to teach the player how the following blocks work:
	- Rails
	- Mirrors
- As the player solves these obstacles, the walls will come down, slowly opening up more of the room.
- After completing these starting obstacles, the player will have access to the Red Wing.
### Central Chamber (Main Config)
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

**Overview**
- Player begins in West section of the Red Wing. This is a winding, overgrown section filled with monsters.
- Reaching the end gives the player the *Blue Key*.
- From the Red treasure room the player can drop down into the first section of the Blue Wing.
- Player descends through 3 rooms, using the stasis spell to unlock a series of gates.
- Upon reaching the end of this hallway, the player fights a miniboss.
- Defeating the miniboss allows the player to unlock the *Stasis* spell.
- Player uses *Stasis* to ascend back the way they came.
- Player enters Northern Blue Wing.

[[demo_script]]
### Western Red Wing
**This section grew around the main power conduit. Due to the abundance of water and energy, this area has flourished, being home to multiple different species of flora and fauna. The Red Wing is split in half by the Orange Wing.**

Area is built on a 3x4 structure. It will consist of mostly platforming and combat challenges, but should have at least 1 stasis challenge.

*v0.4.23*: Main platforming challenges created.
*Todo*: Combat and stasis puzzles [[Roadmap#v0.4.x|see here]].
### Southern Blue Wing
**This section was the coolant for the machine and is located mostly underneath the other wings. It is split in two, similar to the Red Wing.  Unlike the Red Wing, however, these two sections are contiguous.**

Area is built on a 6x1 structure. The puzzle challenges are contained in rooms c, d, & e. The first time the player traverses these rooms (West-East), they solve transmutation puzzles to open gates. At the end of the hallway, the player will fight a miniboss and obtain the Stasis spell.

**Starting Puzzles**:
These could likely be similar to Stasis puzzles, but use buttons instead.

**Stasis Puzzles**:
Instead of an infographic, these puzzles could communicate the concepts behind the Stasis spell.
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
### Northern Blue Wing
This section will be accessible from Southern Blue Wing room b by ~~using a Golem to parkour into a pipe~~. It will be primarily puzzle based, focusing on the Stasis spell the player now has access to.

>[!note] Ramping up of scope
>I think this would be a good place to start increasing the puzzle scope. So far (v0.4.25), all puzzles have only had 1 layer to them.

- I want this section to work as a giant puzzle box, where solving puzzles move giant mechanisms the player can watch.
- The player is turning on the coolant system.

- *Think of the chambers as part of the mechanism moving the setpiece mechanisms. Hydraulics, pipes, wires.*
	- Chamber 1 will lower the first barrier
	- Chamber 2 lowers the water level
	- Chamber 3 raises the second barrier
	- Player must manipulate water level and barriers to escape final obstacle in room?
		- Player would unlock passageways that would let them get around the barriers even when they're up.
		- Chamber 2 is technically 3 chambers which control the water level (none, low tide, high tide). These 3 subchambers depend on mechanism in central room which ensures only one is active at a time.
#### Chamber 1
- Player enters Front Room and sees a bunch of moving parts. The source of this movement is currently hidden.
- Player sees a passageway they can platform to, using the moving parts.
- Thru this passageway the player discovers the Geyser Engine powering the moving parts.
- The player is able to manipulate the Geyser Engine, indirectly manipulating the Front Room puzzle blocks.

This puzzle will be divided into two parts. The first section will require the player to input a security code, engaging the airlock safety feature. This will prevent them from being destroyed by the coming tidal wave.

The second part first requires the player to platform over to the Geyser Engine using the pistons. Once inside this room, the player will use Stasis to lock the system into a desirable state. This will allow the 

Once the player solves the puzzle, an animation will play. The pistons will start speeding up. Cut to the central NBW chamber, where the large gate is being lowered. A rush of water pours over the top, crashing into the airlock
### Orange Wing
This section is actually inside of the power conduit found in the Red section. The two side chambers sticking out from Room3 will take the player outside of the inner sheath. They'll still be in the conduit, but it'll be a bit more obvious (mb there will be a section with a large tear that can be seen from Red.

Here the player will be turning on the power.
### Eastern Red Wing
### Magenta Wing
**This is the control panel.**
The player will ascend up the true control panel. At the apex, they'll have the ability to turn on the machine. If they choose to do so, the game will end. The game should save right before they do so, however, so that they can reload the game and finish the final bits of the demo.
### Purple Wing
Dropping down from the Magenta Wing, the player will find themselves in a large, foreboding room. It is here that they'll fight the final boss of the dungeon.
## The Ascent
After solving the stasis dungeon, the player reenters the ziggurat, this time with access to the top of the pillars. The player will follow a counter-clockwise path to the surface. There are 7 pillars, I don't know whether each one should have some form of challenge, or just a few.

On the top-most pillar there will be an out-of-order elevator. In the actual game, this is what the player will use to reach the surface.