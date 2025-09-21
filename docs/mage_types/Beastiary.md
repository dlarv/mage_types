# Traits
- Overworld behavior
	- How monster moves outside of battle.
	- How monster reacts when seeing player.
- Battle characteristics
	- What makes fighting this monster unique, if anything?
	- Signature moves/equipment
- Variants
	- Are there any unique variations on the basic enemy?
	- Do differently aligned monsters have different characteristics, or are they just a palette swap.
# General Monsters
## Slimes
These will be very basic monsters, just oozing around the overworld. Small slimes will only have one type (*I think this can be done by making BattleActor.element1 = Blank. I can then make some small code alterations so the model doesn't show gray*). 

```tinychart
hp, 100
melee attack, 90
melee defense, 100
ranged attack, 90
ranged defense, 100
speed, 50
```

## Elementals
These will be amalgams of raw elemental energy. They'll always start as E1=E2, but the out fringes have less alchemic inertia, allowing them to transmute. All Elementals will have an item equipped which has a change to revert their secondary type back to their primary. They'll have a chance to drop this when defeated.

```tinychart
hp, 120
melee attack, 30
melee defense, 100
ranged attack, 100
ranged defense, 30
speed, 100
```

## Mages
Other humans which have lost their minds before fully mutating. These will mostly be bosses, but the entry is here for completeness.
# Bias Beasts
Name needs work. These are former humans which have fully mutated to their aligned element.
## Blue Coralized Mage
As a Blue-aligned sits unmoving, lost in their own mind, their body begins to encrust with coral. They don't seem to mind, some even take pride in the size and vibrancy of their new shell.
```tinychart
hp, 130
melee attack, 50
melee defense, 130
ranged attack, 50
ranged defense, 110
speed, 20
```
## Mold Spawn
Sometimes, the thoughts Blue mages are left with are dark. Falling to despair, these mages are overtaken with mold and fungus, which poison the air around them with their spores. The psychic weight of their gloom is sometimes enough to makes others losing their minds.

```tinychart
hp, 130
melee attack, 30
melee defense, 100
ranged attack, 100
ranged defense, 90
speed, 20
```
## Wraith
Purple monsters who have succumbed to the darkness. Tall, dark monsters with glowing eyes. They attack with long, slashing claws. Tactical and careful, these monsters prefer to ambush their prey, inflicting *flinch* on their first turn.
```tinychart
hp, 50
melee attack, 110
melee defense, 90
ranged attack, 110
ranged defense, 90
speed, 130
```

## Spectre
These Purple monsters lack the aggression of their Wraith counterpart. By themselves, these don't pose much of a threat, though some may find their multi-eyed gaze deeply unsettling. Spectres are known to heavily rely on debuffs/buffs, which make them dangerous when paired with any other monsters.
```tinychart
hp, 100
melee attack, 10
melee defense, 120
ranged attack, 10
ranged defense, 120
speed, 80
```
## Jester
The ultimate goal for many Magenta mages is to create an attraction to bring joy to those around them. Jesters embody this passion, making them great supports.
```tinychart
hp, 130
melee attack, 50
melee defense, 120
ranged attack, 50
ranged defense, 110
speed, 80
```
## Barker
A more aggressive variant of the Jester, these Magenta-aligned are more aggressive and sinister. Usually, this takes the shape of carnival style attractions, where the player is doomed to lose. Other times, these attractions can be deadly/unethical games.
```tinychart
hp, 130
melee attack, 40
melee defense, 110
ranged attack, 40
ranged defense, 100
speed, 90
```
## Cryptkeeper (Penitent?)
These Red monsters patrol the gloomy depths of the catacombs. Extremely hostile to any non-Red outsiders (and even some Reds). These monsters specialize in recoil damage moves, helping the player whittle down their impressive hp stat.
Quadrapede?
```tinychart
hp, 200
melee attack, 120
melee defense, 100
ranged attack, 10
ranged defense, 10
speed, 50
```
## Chapelkeeper
These Red monster are unique, as they retain some semblance of sanity, their mind supported by the hivemind. Over time, this will weather down any individuality they once had, leaving them entirely devout to the will of RED. So maybe not too sane. In battle, they employ vampiric attacks which heal them using their opponent's blood.

```tinychart
hp, 100
melee attack, 130
melee defense, 80
ranged attack, 90
ranged defense, 80
speed, 60
```
## Rogue Vessel
Some Orange mages take to role of Vessel, storing vast repositories of knowledge instead of research. This is an important task, with many redundacies, as occasionally Vessels go rogue. Though highly intelligent, these monsters frequently struggle to sift through the vast amount of knowledge they contain. Visually, these creatures are vaguely brain shaped, with many clusters of eyes. They prefer to fire spells from afar.

```tinychart
hp, 100
melee attack, 40
melee defense, 40
ranged attack, 150
ranged defense, 50
speed, 120
```
## Rogue Researcher
Most Orange mages take the role of Researcher, adding knowledge to the repositories contained within the Vessels. But sometimes, their hunger for knowledge manifests in a more literal form. These monsters feature many mouths and tongues, which they will use in an attempt to gobble up anything around them that moves.

```tinychart
hp, 100
melee attack, 110
melee defense, 50
ranged attack, 120
ranged defense, 50
speed, 150
```
## Spaz
These Yellow monsters are rarely seen, as they tend to evaporate fairly quickly. Yellow mages are known for their unshakable carefree demeanor. However, if and when something does cause them to spiral, Yellow mages will become a Spaz. More of an environmental hazard, as they shoot flashes of lightning and Yellow energy at everything around them. If the player does manage to fight them, they'll find most of their attacks do recoil damage.
```tinychart
hp, 60
melee attack, 10
melee defense, 110
ranged attack, 90
ranged defense, 150
speed, 130
```
## Songbird
These Yellow monsters have lost all perspective. In what can only be described as an oblivious attempt to share their joy and flight, these monsters will grab anything that makes them smile, fly up really high, only to get distracted, dropping whatever (or whoever) they happened to be carrying. Any attempts to fight them are mistaken for a game, as nothing can truly hurt these creatures.
```tinychart
hp, 100
melee attack, 50
melee defense, 120
ranged attack, 50
ranged defense, 130
speed, 130
```
## Crystal
Despite their tough appearance, you will quickly find that these Green monsters are brittle. Literal glass cannons, these monsters use their sharp spines and radioactive aura to take down their prey.
```tinychart
hp, 80
melee attack, 130
melee defense, 30
ranged attack, 130
ranged defense, 30
speed, 130
```
## Wyrm
Much more serpentine in appearance, these Green monsters are more bulky than their Crystalline counterparts, but not by much. These monsters use their ranged breath attack to poison their prey, before finishing it off with its fangs.
```tinychart
hp, 100
melee attack, 90
melee defense, 50
ranged attack, 130
ranged defense, 50
speed, 130
```
## Sapphire 
These Cyan monsters are composed of solid metal. Though very heavy, these quadrapedes are capable of surprising bursts of speed (priority attacks). 
```tinychart
hp, 100
melee attack, 40
melee defense, 150
ranged attack, 40
ranged defense, 150
speed, 60
```
## Diamond
A Cyan mage returns after being lost in a snow storm. Suddenly, they're cold and distant, a complete 180 from their initial personality. Tragically, while this looks like their lost friend, the community soon realizes they have yet to return. If they do not realize soon enough, they will once the monster attacks. Once they snap, the Diamond will undergo rapid changes. Their steely skin turns clear like ice, losing some of their trademark durability. 

```tinychart
hp, 100
melee attack, 80
melee defense, 80
ranged attack, 10
ranged defense, 120
speed, 90
```

## BST
These are all hypothetical numbers, really only useful for comparing a monster's stats to itself. Still, I think its interesting to see which monsters I gave high totals to.
```tinychart
coral, 490
mold, 470
wraith, 580
spectre, 440
jester, 540
barker, 510
crypt, 490
chapel, 540
vessel, 500
researcher, 580
spaz, 550
songbird, 580
crystal, 530
wyrm, 550
sapphire, 540
diamond, 480
```
# Blue Area Monsters
These are monsters found in the Hotel, Beach, Caves, and Poolroom areas.
## Crinoid
Blue, Blue
These monsters resemble the thing Cradily and Lileep (Pokemon) are based on. They have a bulbous, flower like head atop a thin stalk. Their base has 1-3 tentacles that rise upwards, serving somewhat like arms. These monsters are somewhat intelligent, however they seem more interested in eating people rather than talking with them.

This used to be the monstrous result of Blue-alignment, but it felt too far removed from the other, more humanoid mutations.
## Starfish
Blue, any
Slow and lumbering, they inch towards their prey, smashing them with their heavy arms.
Very large enemy, I'm picturing it taking up almost an entire room. They'll have large spines on their arms, which reflect their secondary type.
## Ice Wyrm
Cyan, Green 
These strange creatures live on and around the ice machines found throughout the hotel.
## Imp
Purple, Purple
Wispy and fast. Mostly seen as a blur of blades and teeth.