# TLDR
Okay, so here's the TLDR. The central mechanic of this game is the *transmutation system*. There are 8 *elements*, each named after a color. When two elements come in contact, they transmute into another. So Red + Yellow => Orange. See, its so simple, nothing else to it (Please ignore the length of the Transmutation System section below...). Inanimate matter can be transmuted, which forms the basis of the puzzles in this game. Living matter, too, is also affected. This forms the basis of the combat.

Right, so there's 8 elements: Blue, Purple, Magenta, Red, Orange, Yellow, Green, and Cyan. I've tried to give each elements its own aesthetic and vibe, so Green is poison, Red is blood, Magenta is clown, typical stuff like that. As people interact with elemental energy, they'll develop an *alignment*, where they permanently become one element (if that sounds like it would break the central mechanic, put a pin in that). Alignment comes with an array of physical, emotional, and magical traits.

Final TLDR, the game takes place in a pocket dimension, inspired initally by liminal spaces/backroom aesthetics. The island is currently named Forlorn, but I'm not super happy with it, so it may be subject to change lol. There are monsters and settlements, but I'm still deciding how empty this world will ultimately be.
# Meta-commentary, or Explaining my Questionable Decisions
## Transmutation
If I'm being honest, creating weird systems and mechanics is my favorite part of game design, and its not even close. For this project, I created the idea of a transmutation-based system first. Everything else was created as a means to contextualize and justify this central conceit. Even the elements, which you would think would play a more foundational role, were originally just placeholders. I think they work best as colors, but that choice was really just a happy accident.

I know the elemental system is complex, esoteric even. And, unfortunately, that is what I enjoy making.
***Insert: Video Essayist Comic***
My dream game (to make) would be cross between Noita and Ena Dream BBQ. A surrealist fever dream with an infinitely complex central mechanic. I'm not aiming for mass market appeal, if I can get just one hour+ video essay about my game, I'll die happy.

Hopefully, that helps contextualize most of the questionable design decisions I've made. I want the game to be fun, but I want to enjoy making it more (this is my hobby, after all). It'd be great to get both, of course, but we will see. Ultimately, I'm just a programmer with a god complex and overinflated sense of my own abilities, but I'm making a 3D somewhat-open-world RPG, so you knew that already :)
## Selecting the Elements
The idea for the elemental system originated from the transmutation reactions from Cassette Beasts. In this game, when an ice-type is hit with a fire-type attack, they transmute into a water-type. I wanted to make a type system based entirely on this idea.

Initially, I wanted the end result to look something like Fire + Wood = Smoke. My plan was to use colors as placeholders until I found an "interesting" looking type chart, then retrofit the labels (in hindsight, a truly insane way to go about doing this, but I digress). Instead of colors, I could have used letters or numbers, but colors made the type chart easier to read at a glance. Figuring the best way to test this process was mixing the colors, I started pluggin them into an online paint mixer. This was quickly followed by the realization that I did not know what constituted an "interesting" type chart. So, with a "functional" system, I decided to move forward.

You probably know this already, but each color is composed of 3 channels: Red, Green, Blue (at least on the computer). I've since adjusted the hues, but originally these were very "mathmatical." 
Red, Green, and Blue each consist of 1 maxed out channel. 
Magenta, Yellow, and Cyan each have 2 maxed out channels. 
Purple and Orange each have 1 maxed channel and 1 channel at 1/2 strength.
Originally, I was going to include Pink, but it was too difficult to distinguish Magenta, Pink, and Purple at a glance. Similarly, I didn't include Azure and Spring Green (I thought this was called Seafoam).
I don't like chartreuse.
***Insert graphic to replace above info***
	
The table below shows every possible combination of colors, along with which of the following rules I applied:
1. **Resembles** A color mixing with another cannot form itself. So Red + Orange = Orange isn’t valid.
2. **Exact** If the result is a valid element, then its result is straightforward (Blue + Magenta = Purple).
3. **Proportional** If the result is just a darker version of an element (Red + Green = Dark Yellow = Yellow).
4. **Maxed** If a color channel is maxed out, then the result should be that color (Yellow + Cyan = Green, b/c green channel is FF).

| Color 1                                   | Color 2                                   | Result                                    | Selected Color                            | Rule     |
| ----------------------------------------- | ----------------------------------------- | ----------------------------------------- | ----------------------------------------- | -------- |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#00FF00">00FF00</span> | <span style="color:#808000">808000</span> | <span style="color:#FFFF00">FFFF00</span> | 3        |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#0000FF">0000FF</span> | <span style="color:#800080">800080</span> | <span style="color:#FF00FF">FF00FF</span> | 3        |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#FFFF00">FFFF00</span> | <span style="color:#FF8000">FF8000</span> | <span style="color:#FF7F00">FF7F00</span> | 2        |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#00FFFF">00FFFF</span> | <span style="color:#808080">808080</span> | None                                      | No Match |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#FF00FF">FF00FF</span> | <span style="color:#FF0080">FF0080</span> | None                                      | 1        |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#FF4000">FF4000</span> | None                                      | 1        |
| <span style="color:#FF0000">FF0000</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#C00080">C00080</span> | <span style="color:#FF00FF">FF00FF</span> | 3        |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#0000FF">0000FF</span> | <span style="color:#008080">008080</span> | <span style="color:#00FFFF">00FFFF</span> | 3        |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#FFFF00">FFFF00</span> | <span style="color:#80FF00">80FF00</span> | None                                      | 1        |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#00FFFF">00FFFF</span> | <span style="color:#00FF80">00FF80</span> | None                                      | 1        |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#FF00FF">FF00FF</span> | <span style="color:#808080">808080</span> | None                                      | No Match |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#80C000">80C000</span> | <span style="color:#FFFF00">FFFF00</span> | 3        |
| <span style="color:#00FF00">00FF00</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#408080">408080</span> | <span style="color:#00FFFF">00FFFF</span> | 3        |
| <span style="color:#0000FF">0000FF</span> | <span style="color:#FFFF00">FFFF00</span> | <span style="color:#808080">808080</span> | None                                      | No Match |
| <span style="color:#0000FF">0000FF</span> | <span style="color:#00FFFF">00FFFF</span> | <span style="color:#0080FF">0080FF</span> | None                                      | 3        |
| <span style="color:#0000FF">0000FF</span> | <span style="color:#FF00FF">FF00FF</span> | <span style="color:#8000FF">8000FF</span> | <span style="color:#7F00FF">7F00FF</span> | 1        |
| <span style="color:#0000FF">0000FF</span> | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#804080">804080</span> | <span style="color:#7F00FF">7F00FF</span> | 3        |
| <span style="color:#0000FF">0000FF</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#4000FF">4000FF</span> | None                                      | 1        |
| <span style="color:#FFFF00">FFFF00</span> | <span style="color:#00FFFF">00FFFF</span> | <span style="color:#80FF80">80FF80</span> | <span style="color:#00FF00">00FF00</span> | 4        |
| <span style="color:#FFFF00">FFFF00</span> | <span style="color:#FF00FF">FF00FF</span> | <span style="color:#FF8080">FF8080</span> | <span style="color:#FF0000">FF0000</span> | 4        |
| <span style="color:#FFFF00">FFFF00</span> | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#FFC000">FFC000</span> | <span style="color:#FF0000">FF0000</span> | 4        |
| <span style="color:#FFFF00">FFFF00</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#C08080">C08080</span> | None                                      | No Match |
| <span style="color:#00FFFF">00FFFF</span> | <span style="color:#FF00FF">FF00FF</span> | <span style="color:#8080FF">8080FF</span> | <span style="color:#0000FF">0000FF</span> | 4        |
| 00FFFF                                    | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#80C080">80C080</span> | None                                      | 3**      |
| <span style="color:#00FFFF">00FFFF</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#4080FF">4080FF</span> | <span style="color:#0000FF">0000FF</span> | 4        |
| <span style="color:#FF00FF">FF00FF</span> | <span style="color:#FF7F00">FF7F00</span> | <span style="color:#FF4080">FF4080</span> | <span style="color:#FF0000">FF0000</span> | 4        |
| <span style="color:#FF00FF">FF00FF</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#C000FF">C000FF</span> | <span style="color:#0000FF">0000FF</span> | 4        |
| <span style="color:#FF7F00">FF7F00</span> | <span style="color:#7F00FF">7F00FF</span> | <span style="color:#C04080">C04080</span> | <span style="color:#FF00FF">FF00FF</span> | 3        |

\*\*This mistake, this mistake right here... This is 1 of 2 data entry errors I made. This one is much more of a problem, as it has ramifications. 

See, one of the weaknesses of this mechanic is how difficult it is to memorize the type chart. But there's a few shorthand rules you can use.

Most reactions that include a primary color are fairly straight forward.
<span style="color:Red">Red</span> + <span style="color:Blue">Blue</span> => <span style="color:Magenta">Magenta</span>
<span style="color:Red">Red</span> + <span style="color:Green">Green</span> => <span style="color:Yellow">Yellow</span>
<span style="color:Blue">Blue</span> + <span style="color:Green">Green</span> => <span style="color:Cyan">Cyan</span>
<span style="color:Red">Red</span> + <span style="color:Yellow">Yellow</span> => <span style="color:Orange">Orange</span>

These ones technically use the same principle, but its necessary to understand that Orange and Purple are functionally Red and Blue. 
<span style="color:Orange">Orange</span> + <span style="color:Blue">Blue</span> => <span style="color:Magenta">Magenta</span>
<span style="color:Red">Red</span> + <span style="color:Purple">Purple</span> => <span style="color:Magenta">Magenta</span> 
<span style="color:Orange">Orange</span> + <span style="color:Purple">Purple</span> => <span style="color:Magenta">Magenta</span> 
<span style="color:Orange">Orange</span> + <span style="color:Green">Green</span> => <span style="color:Yellow">Yellow</span> 
<span style="color:Purple">Purple</span> + <span style="color:Green">Green</span> => <span style="color:Cyan">Cyan</span> 

The final principle is where the aforementioned error arises. Reactions that are between secondary/tertiary colors can be understood by looking at which channels overlap.
<span style="color:Yellow">Yellow</span> + <span style="color:Cyan">Cyan</span> => <span style="color:Green">Green</span> 
<span style="color:Yellow">Yellow</span> + <span style="color:Magenta">Magenta</span> => <span style="color:Red">Red</span> 
<span style="color:Yellow">Yellow</span> + <span style="color:Orange">Orange</span> => <span style="color:Red">Red</span> 
<span style="color:Purple">Purple</span> + <span style="color:Magenta">Magenta</span> => <span style="color:Blue">Blue</span>
<span style="color:Purple">Purple</span> + <span style="color:Cyan">Cyan</span> => <span style="color:Blue">Blue</span>
<span style="color:Orange">Orange</span> + <span style="color:Magenta">Magenta</span> => <span style="color:Red">Red</span>
<span style="color:Cyan">Cyan</span> + <span style="color:Magenta">Magenta</span> => <span style="color:Blue">Blue</span>

But this principle doesn't apply for these 2 reactions:
<span style="color:Orange">Orange</span> + <span style="color:Cyan">Cyan</span> => <span style="color:Green">Green</span> (<span style="color:#80C080">80C080</span>)
<span style="color:Yellow">Yellow</span> + <span style="color:Purple">Purple</span> => <span style="color:Red">Red</span> (<span style="color:#C08080">C08080</span>)
I included the raw result from the mixing calculation. The second result doesn't look like Red to me, but the first result does look very Green to me. I had even left a note about how it should be green, but I missed that when I started creating the graphics. If I hadn't missed this, I would hopefully also noticed that the second reaction above should've been Red by the same logic. Now, the reason that these 2 reactions are borderline is because of the second principle above (Orange=Red and Purple=Blue). But in hindsight, I'd rather not have this exception.

Dlarv, I hear you say, why don't you just change the transmutation system to add these transmutation in? Good question, because of this:
***Insert transmutation graph***
Initially, I was using a more traditional type chart, but the above graphic is far better at communicating the information. 
1. This graphic was an absolute pain to create and I don't want to have to recreate it.
2. This graphic is much harder to read when any of the arrows cross each other. The updated graphic has no configuration I can find where there are no overlap

![[graph_updated.png]]
I could probably change this, I probably should change this, but that's a future Dlarv problem.
## Alignment
The player, as well as every(most?) humans that find themselves on Forlorn, has been isekaied. They fell thru a crack in reality and landed in this strange, liminal world. The matter in their bodies starts off as carbon/etc, with them slowly changing into the color-based matter native to the island. This process is pretty much inevitable, but it can be sped up by using magic, getting injured, etc. Alignment is what happens when this conversion concludes, permanently locking their core into one element. Great enough damage can force this core to transmute, but this is always fatal. As such, complex organisms (like the player) have an outermost shell which can react. This acts as a pressure release valve, directing alchemic energy away from the core. In gameplay, the player has a primary and secondary type.
	
In lore, alignment comes with several physical, behavioral, and magical traits. I tried to give each Element its own flavor. I also wanted to explore the idea of a magic system that mutates you, making you better at wielding its power, at the detriment of other skills. Alignment is a big commitment. It also has some body horror to it, an aspect I want the player's main companion's arc to explore. Some powerful monsters used to be mages, though I've scaled this idea back, mostly because I'm thinking I want the world to feel a bit more empty and alien (less people => less monsters).
## The Combat System (Transmutation in Practice)
So hopefully you've been following so far, because this is the part where we start to go off the deep end.
### Level 1: Transmutations
Each combatant has 2 types: primary and secondary. Their primary type never changes, not during battle at least. When a character has an alignment, their alignment is the primary type. Before the player develops an alignment, there primary type has the chance to change every time they level up.

A combatant's secondary type changes frequently, sometimes multiple times a turn. When a combatant is hit, their secondary type will react with the attack (if a reaction exists). Fair enough. But then, their secondary type will react with their primary. The logic for this is that the secondary type is a layer that rests on the primary. The primary type is also like a core radiating out elemental energy.

Normally, this will only affect the *target* of an attack. But if the move is a melee attack, it will also affect the *user*. Each attack lands with a burst of elemental energy, so in close quarters this will also affect the user.
***Insert examples table***
### Level 2: Side Effects
Pretty early in the design process, I realized there was a major issue. The central mechanic was transmutation, but the player had no reason to actually care about it. Like, a combatant would turn Red, but that didn't do anything. I had a few ideas, one of which being the side effects.

Every time a transmutation occurs, they'll get a stat boost. What stat boost? Depends!

The Elements are separated into 2 "affinity" groups, offensive and defensive. These aren't the best labels, because defensive types have damage attacks and vice versa, but they're the best labels I have, so.... 
***Insert table showing groups***

The astute among you might notice that this introduces an amount of power creep into every battle. This adds a layer of strategy, as if you do not transmute often enough you'll find yourself outpaced by your opponents. I think its good conceptually, it may be a hacky method to force the player to engage with transmutations, but its my hacky method.
### Level 3: STAB
For any non-Pokemon-nerds reading this, STAB stands for Same Type Attack Bonus. Essentially, in Pokemon if a fire-type uses a fire attack, its 50% stronger. Of course, the way that this is implemented in my game isn't as straightforward, but, like, that should be obvious at this point. 

I don't even think its fair to call it STAB, but its STAB adjacent. Essentially, all attacks have something called a scaling factor, which consists of 3 percentages. One, as you might imagine, is the power of this attack if either of the user's types match the attack's type. Exactly like STAB, except instead of being a set percentage, it varies from attack to attack. The other two numbers are for when the user is in the same affinity group (offensive/defensive) as the attack and for when the user shares no type or affinity group.

So for Pokemon, all attack scaling factors would look like: 100/100/150.

Admittedly, this is pushing it, but this system is pretty lowkey, so the player doesn't really need to engage with it. Like, most attacks might have factors like 100/100/100. A few attacks have 100/100/200, but say in their description that they deal double damage when the player is x-type. Basically, its set up in a way where the player might not even realize its there until they get some late game attack that has crazy factors.
### Level 4: Nothing Wrong With Me
So, that's enough about the current elemental system. But I'm worried you think I have no restraint and just keep adding stuff. Fair, but also:

I'm hoping I'm just overthinking the side effects, they feel pretty simple to me, especially now that I've rewritten the battle tutorial to be more structured. But if you think its bad now, you should know that this is the simplified version. 

Originally, each reaction had its own unique side effects. 2 stats would be sharply boosted and 1 would be slightly lowered, all based on the vibes of each Element. But that was bloated, so I cut it.

Speaking of needless compexity, I at one point tried to add a weakness/resistance system, like in more traditional type systems. Luckily, trying to write the tutorial for that proved impossible, which was a lowkey wakeup call to ax it.

So yeah, I know that its a lot, but know that I am *trying* to incorporate player feedback to streamline the transmutation system into something manageable. I intend at some point to add icons for each type, as well as shift the hues around to better match the mood and make them easier to distinguish. I plan to do a big Elemental update, the whole system is built on a prototype, so there are some optimizations and fixes I need to do on the backend (and I should probably add the missing reactions...)
## The Elements (Brief)
In section 3 of this document, I plan to include a few vibe and narrative peices that will help flesh out my ideas about each Element. But this section here serves as a brain dump of the broad strokes.
### Blue
- **Affinity**: Defensive
- **Combat roles**: Transmutation control, Speed control
- **Compare to**: Astral, Water
- Stagnation, stasis, fungus, deep sea (minor)
### Purple
- **Affinity**: Offensive
- **Combat roles**: DPS, Support(debuffing)
- **Compare to**: Psychic, Dark, Beast
- Shadows, underhanded tactics, pack hunters
### Magenta
- **Affinity**: Defensive
- **Combat roles**: Support, Tank
- **Compare to**: Fairy, Glitter
- Clowns, Carnivals, Creative process
### Red
- **Affinity**: Offensive
- **Combat roles**: DPS, Tank
- **Compare to**: Beast, Ground, Plant
- Blood/Bone, Vampires, Cult
### Orange
- **Affinity**: Offensive
- **Combat roles**: DPS, Transmutation control
- **Compare to**: Fire, Plastic
- Science, Slime
### Yellow
- **Affinity**: Defensive
- **Combat roles**: Support, Speed control
- **Compare to**: Air, Light, Electric
- Flight, Optimism
### Green
- **Affinity**: Offensive
- **Combat roles**: Hyper-offense
- **Compare to**: Dragon, Rock, Poison
- Poison, Radiation, Punk, Reptiles
### Cyan
- **Affinity**: Defensive
- **Combat roles**: Tank
- **Compare to**: Ice, Steel
- Rugged, exploration, engineering
## Conclusion
Thank you for taking the time to read thru the introduction. I tried to explain the fundamentals as thoroughly as I could, hopefully it was coherent lol. But this concludes the introductory sections of my pitch document. The next section has a few narrative and vibe pieces I wanted to write to explore the Elements. Basically, I'm trying to flesh out the 'personality' of each Element.
# The Elements
## Blue
*Defensive*
Blue forms much of the structural core of the island. As such, its a stable element, prone to and stagnation. Mages that channel its power form a deeper understanding of the fabric of reality, at a cost. Blue is unconcerned with the details of other elements, a trait it passes along to its mages.

Blue magic gives its users control over the pacing of their battles, both through speed control, as well as master over the *Stasis* status condition (prevents transmutations from occuring until the end of the turn).
## Purple
*Offensive*
Gloom and grief take form, the element of Purple haunts the island's shadows. Observant and patient, Purple is the chosen magic of ambush predators and assassins.

Purple magic is used by hunters to reveal the weakpoints in their prey. 
#todo
## Magenta
*Defensive*
Dreams on the island are woven from Magenta. While native matter can be formed from any of the 8 elements, Magenta always plays a role, manifesting concepts and ideas into reality. As such, artists and creatives are frequently drawn to this element. 
## Red
*Offensive*
# Transmutation and Alignment
# The Map
# Factions