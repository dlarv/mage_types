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

>[!idea] Employee Breakroom
>Next to the front desk will be Employee Breakroom \#1, which is little more than a closet. It contains a chair and a microwave. Entering a specific code into the microwave will open a portal to Magenta Classic, which is a large fairground.
>
>There should be another breakroom labelled on the map, which will be \#3, hinting at the existance of the fairground. It could also be an interesting red herring impying that something tragic happened to breakroom \#2.
>
> A hint for the proper code should be hidden somewhere on the map (all microwaves outside of the breakrooms are locked on a specific time).
## Beach
- Player will spawn on lighthouse pier.
- They'll find themselves on a lonely nighttime beach. In the distance is an old, abandoned house.
- Inside the house should be an introduction to the transmutation system.
![[stencil_bpm.png]]
## Hotel
- Battle Tutorial: Inside Rec Room.
- First boss inside hall1, forcing player to backtrack to Rec Room if they don't understand how to fight.
- There should be some items hidden inside of simple hotel rooms.
	- Some rooms should look normal, but some should be bizarre.
- I'll take the hidden cave puzzle (Lavender's puzzle) and put it inside of a middle section of the hotel.
- World geometry will get weirder the further the player is from the main path.
	- I.e. infinite hallway, path to Lavender's puzzle.
### Rec Room
-  [[discussions/old_battle_tutorial|Original Battle Tutorial]]
- High level boss is camped out in hall 2. Player will likely be defeated and forced to backtrack to rec room.
- An enclave is camped out in the Rec Room. This enclave is very focused on fitness and combat, and thus is more than happy to give the player a hand. 
- Player will receive 150 exp from this fight, allowing them to level up twice.
- Player will also receive several spell beads, ultimately a Strike attack.

1. Introduce concept of transmutations.
	1. Primary and secondary types.
2. Mention how melee attacks also transmute the player.
3. Side effects.
4. Attack scaling factor.
- Inform player about how alignment can ultimately end with insanity (when they explain why the hall2 monster is aggressive but they are not).
- Clarify that no super-effective damage exists.
- Teach player how to equip new spells.

>[!note]
>I think it would be helpful to introduce the player to the transmutation system before the battle tutorial. Maybe use the laser puzzle concepts from the first demo.
>
>I could place a transmutation puzzle inside of the beach house. I was thinking about getting rid of the original caretaker, so I could instead make it rundown and abandoned, to add to the ambiance.
#### Tutorial 1
**Objectives**
- Introduce Primary and Secondary type.
- Explains transmutation hint.
- Melee attacks also transmute user.
- Side effects might be mentioned, but I don't really want to focus on them here.
	- I'm considering adding an equipment that will turn off side effects.
	
**Starting Config**
- Player (Blue/Blue)
	- Magenta Throw (*Attack*)
- Boss (Blue/Blue)
	- Blue Hit (*Attack*)
	- Red Hit (*Attack*)
	- Training Wheels? (*Equipment*): turns off side effects
	
**Dialog**	
>**Turn 0**
> To start, select an attack from the menu below. You likely only have one currently.
> Then click on me to select your target. 
> You'll notice a strange popup when you do. This is called the [i]Transmutation Hint[/i]. 
> Right now, just remember to color of the top-right square.
>*Player is given control to select attacks*

>**Turn 1a**
> Unlike most other things in this world, combatants actually have two types.
> Your [i]primary[/i] type is the composition of your inner core. It has a lot of inertia and will not change during battle.
> Your [i]secondary[/i] type is the composition of your outer crust. This thin crust is highly reactive, frequently changing multiple times per turn.
> Pay attention to my left (your right) side when you attack.
> *Boss uses Blue Hit (12dmg)*
> *Player uses Magenta Throw (15dmg)*

>**Turn 1b**
> Notice how my [el]Blue[/el]  [i]secondary[/i] type reacted with your [el]Magenta[/el] attack to form [el]Purple[/el].
> As I mentioned, your [i]secondary[/i] type is highly reactive, reacting to any element it comes into contact with.
> This largely applies to your opponent's attacks. However, your [i]secondary[/i] type will also react to your own [i]melee[/i] attacks, since you're channeling that energy in close quarters.
>Additionally, your [i]secondary[/i] type will react with your [i]primary[/i] type (Only your [i]secondary[/i] will change, of course).
>My next attack will be a [el]Red[/el] melee attack, which will demonstrate these effects.
>*Control is returned to player*

>**Turn 2a**
>*Boss uses Red Hit (6dmg)*
>*Player uses Magenta Throw (21dmg)*

>**Turn 2b**
>You'll also notice that your transmutations had side effects, which are just stat buffs.
>Dallas will teach you a bit more about these in the next lesson.
>If you're wondering why I haven't had any side effects during this battle, its because I have an item which turns them off. It makes describing the battle mechanics much simpler, don't you think!
>Well, that everything I have to teach you. Why don't you finish up this fight and Dallas will pick it up where I left off.
>*Control is returned to player*
>*Player's next attack will be guaranteed to defeat Aegean (20dmg)* 

**Rewards**
- Core realigns to Purple.
- Enough xp to level up
	- Hp: 50 -> 55
	- MAttack: 8 -> 12
	- RAttack: 8 -> 11
	- MDefense: 10 -> 12
	- RDefense: 10 -> 13
	- Speed: 10 -> 11
- Purple Hit (*Attack*)
#### Tutorial 1.5 (Equipping Spells and Equipment)
#### Tutorial 2
**Objectives**
- Affinity groups
- Side effects

**Dialog**	
>**Turn 0**
> Suuup. So right, affinities!
> So the elements of this world are split into 2 [i]affinity[/i] groups: [color=red]offensive[/color] and [color=blue]defensive[/color].
> You've noticed the sword and shield icons next to your attacks, right? Those will tell you which [i]affinity[/i] group that attack's element belongs to.
> Its a bit confusing, but these [i]affinity[/i] groups don't actually have anything to do with whether an attack does damage.
> Like, [el]Blue[/el] is a [color=blue]defensive[/color] type, a lot of its moves will be support or defense focused, but there are [el]Blue[/el] attacks.
> You can find the full list inside your [i]Transmutation Menu[/i].
> *Control is returned the player*

>**Turn 1a**
> Every time you transmute, there will be side effects, which are, like, stat buffs.
> If you go from [color=red]offensive[/color] -> [color=blue]defensive[/color], you'll get a [color=blue]defense[/color] buff.
> If you go from [color=blue]defensive[/color]-> [color=red]offensive[/color], you'll get an [color=red]attack[/color] buff.
> And if you stay within the same [i]affinity[/i] group, you'll get a [color=green]speed[/color] buff.
> This info can also be found inside your [i]Transmutation Menu[/i].
> *Player can use either Purple Hit (32 dmg) or Magenta Throw (16 dmg).*
> *Boss 2 uses Magenta Throw (20 dmg).*

>**Turn 1b**
> So my [el]Magenta[/el] attack only caused one transmutation, so only one side effect, right?
> You went from [el]Purple[/el] to [el]Blue[/el], which are [color=red]offensive[/color] and [color=blue]defensive[/color] types, respectively.
> Right, so your end result was a [color=blue]defensive[/color], so you got a [color=blue]defense[/color] buff.
> If you hover your mouse over the 3rd and 4th dials under your health bar, they will tell you you've a received a 30% buff to both your defense stats!
>>*Player used Magenta Throw*: And since the attack you used was [el]Magenta[/el], I also received a [color=blue]defense[/color] buff!
>>*Player used Purple Hit*: And since the attack you used didn't react at all with me, I didn't receive any side effects. Bummer dude ;)
>*Control is returned to player.*

>**Turn 2a**
> *Boss 2 uses Red Hit, w/+1 priority (15 dmg).*
> *Player can use either of their attacks (26 dmg).*

>**Turn 2b**
> That was a lot of side effects just then, but I hope you were able to follow all of that.
> Every action a combatant can have like, up to 4 transmutation and therefore 4 side effects!
> And if one side transmutes more often than the other, battles can become pretty one sided.

**Starting Config**
- Player (Purple/Purple)
	- Magenta Throw (*Attack*)
	- Purple Hit (*Attack*)
- Boss 2 (Blue/Purple)
	- Magenta Throw (*Attack*)
	- Red Hit (*Attack*)
	
**Rewards**
- Half of the xp needed to level up
- Hydrophobia (*Attack*)
- Denim joins your party
#### Tutorial 3
**Objectives**
- Touches on side effects
- Acts as a final lesson before the player fights the miniboss. Unlike the previous two fights, the player can lose this fight
- Player will have Denim in their party, allowing them to get a feel for the team aspect of the combat system

**Dialog**
> 

**Starting Config**
- Player (Purple/Purple)
	- Magenta Throw (*Attack*)
	- Purple Hit (*Attack*)
	- Hydrophobia (*Attack*)
- Denim (Purple/Blue)
	- Blue Throw (*Attack*)
	- Magenta Hit (*Attack*)
	- Shield (*Attack*)
- Boss 2 (Blue/Purple)
	- Magenta Throw (*Attack*)

**Rewards**
- Rest of xp needed to level up
- Willpower (*Equipment*)
### Supply Closet
This is where I test and demo all puzzle blocks. In the back of this section there will be a door to the Backrooms, which are a Lost Forest style puzzle where the player must use their knowledge of Offensive/Defensive elements to navigate it.
## Caves
This website can be used to create procedurally generated cave maps: https://watabou.itch.io/cave-generator.
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
- 4 Lasers will be arrayed around the edges of the room. Each one hits a hidden receiver.
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
- Chamber 1 will lower the first barrier.
- Once the first barrier is lowered, the main chamber will be partially flooded.
- Past the first barrier, the player will be tasked to turn on the cooler's pump.
- Five valves must be opened in a specific order, but one is missing its wheel.
	- The player could be given 3 hints, each describing a distance away from a particular feature in the main room. Player can use these hints to triangulate the hidden wheel's location.
- The actual pump will be a 3-gear Vortex Engine.
- Once the area has been totally solved, the Western side of the main chamber will lower, allowing the player to re-enter the central chamber of the Stasis Dungeon.
	- The doorway will be raised slightly, relative to the main chamber, creating a waterfall. Channels cut into the floor of the main chamber will flood.
#### Chamber 1
- Player enters Front Room and sees a bunch of moving parts. The source of this movement is currently hidden.
- Player sees a passageway they can platform to, using the moving parts.
- Thru this passageway the player discovers the Vortex Engine powering the moving parts.
- The player is able to manipulate the Vortex Engine, indirectly manipulating the Front Room puzzle blocks.

This puzzle will be divided into two parts. The first section will require the player to input a security code, engaging the airlock safety feature. This will prevent them from being destroyed by the coming tidal wave.

The second part first requires the player to platform over to the Vortex Engine using the pistons. Once inside this room, the player will use Stasis to lock the system into a desirable state. 

Once the player solves the puzzle, an animation will play. The pistons will start speeding up. Cut to the central NBW chamber, where the large gate is being lowered. A rush of water pours over the top, crashing into the airlock

1. Security code puzzle one #todo.
2. Use pistons to platform to the Vortex Engine.
3. Use Stasis on one of the emitters.
4. Return to the front room.
5. Use Stasis on the NW piston mirror.

>[!note]
>The player should have to use several StasisTargets. This way, if they've already solved the front room, they'll have to redo their Stasis lock. This will prevent the puzzle from being solved when the player isn't present to see it.
#### Valve Puzzle
#### Pump Room
- Similar to the chamber 1, the player is presented with a busy room full of moving mechanisms. They will now likely know that there is a Vortex Engine neaby powering this movement.
- Require use of transmutations and Stasis.
- Moving parts driven by Vortex Engine.
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

On the top-most pillar there will be an out-of-order elevator. In the actual game, this is what the player will use to reach the surface.**