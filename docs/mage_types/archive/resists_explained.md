#discussion
# Intro
I actually created 3 versions of the matchup chart while working on this. The first I filled out using my intuition. I then repeated this without looking at the previous chart to create the second. The third relied more heavily on [[element_theming]]. 

I also worried that filling out the chart element by element would disadvantage elements visited later. To remedy this, I treated every element as if it were the first, ignoring previous resistances (By the time I thought of this, I had already created the first 2 charts, so this really only applies to the third). 

Matchups that seem really intuitive will be treated as canonical and given more weight.

After completing the third chart, I compared all three to try and find the 'canonical' types. [[resists_explained#Matchups Explained|Resistance chart]]

The following matchups were present in all three versions:
- PxB => x2
- OxP => x2
- OxC => x2
- YxP => x2
- GxY => x2
- CxO => x0.5
- CxY => x2

The following had some matchup in every version, with at least 1 value being different:
- PxP (x1, x2, x2)
- RxY (x0.5, x2, x2)
- BxR (x2, x2, x0.5)
- BxG(x0.5, x0.5, x2)
- RxB (x0.5, x0.5, x2)

The matchups between R, G, & B also flipped between v2 and v3, which accounts for the last 3 items in the previous list. I actually think RxB, BxG, & GxR => x2 makes more sense.

*I should note that version 1 and version 3 had the most justification behind them, while I really just winged version 2.*

I think these are solid canidates for the canonical matchups:
- BxG => x2
- PxB => x2
- PxP => x2
- RxB => x2
- OxP => x2
- OxC => x2
- YxP => x2
- GxR => x2
- GxY => x2
- CxO => x0.5
- CxY => x2
# Resistance Chart Summarized

|     |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     | B   | P   | M   | R   | O   | Y   | G   | C   |
| B   | n   | r   |     | wwr | w   | r   | rrw | n   |
| P   | www | nww | r   | w   | rr  | nr  | w   | rr  |
| M   | r   | w   |     | r   |     |     |     | rr  |
| R   | rrw |     | ww  | n   |     | rww | ww  | n   |
| O   | r   | www |     |     | n   | r   |     | www |
| Y   | rr  | www |     | r   | n   | r   | n   | nr  |
| G   | ww  | ww  |     | rrw | w   | www | ww  | rr  |
| C   | nr  | nr  | nr  | nr  | rrr | www | r   | n   |

w = weak to = x2
r = resists = x0.5
n = neutral = x1
# Matchup Explained 
Green and Cyan are the architypical Offensive and Defensive type, so it makes sense for them to have the most supereffective or resistances respectively. I think each having 5 positive matchups is a good ballpark.

**Cyan**
Cyan is a very stalwart element, so it should be able to resist the emotional elements (Magenta and Green).
- G(Emotional)xC(Stalwart) => x0.5
- M(Emotional)xC(Stalwart) => x0.5
This also makes them difficult for Purple to intimidate.
- P(Intimidating)xC(Stalwart) => x0.5

Cyan is also very cold, which slows down Yellow. This does make it vulnerable to explosive Orange.
- C(Cold)xY(Energetic) => x2
- Y(Energetic)xC(Cold) => x0.5
- C(Ice)xO(Fire) => x0.5
- O(Fire)xC(Ice) => x2

**Green**
Due to their fierce aggression, any elements not devoted to defense struggles against their overwhelming might.
- GxP => x2
- GxO => x2
- GxR => x2
They make no exception for other Greens.
- GxG => x2

The ethereal nature makes Yellow tough to deal with for most grounded elements. Green, however, makes good use of their energy attacks, allowing them to punish this frailer element.
- GxY => x2

**Purple**
Purple is also highly aggressive element, using darkness and fear to defeat their foes.

Purple channels much of the same power as Blue, focusing much more on combat and strength. This gives them an advantage against Blue.
- PxB => x2
Like Green, they are effective against themselves.
- PxP => x2

The negative emotions surrounding Purple struggle to bring down optimistic Magenta, and vice versa.
- PxM => x0.5
- MxP => x0.5

**Yellow**
Yellow is a very gaseous type, making it resistant to the other physical elements.
- RxY => x0.5
- OxY => x0.5
- YxY => x0.5

Yellow is bright and energetic, making it effective at countering Purple.
- YxP => x2
- PxY => x0.5

**Orange**
Orange is a chaotic element, wielding explosions and fire.
- O(Fire)xC(Ice) => x2
- CxO => x0.5
This fire brings light into the dark caves of Purple.
- OxP => x2

**Blue**
Blue is like a vast ocean, snuffing out the fires of Orange.
- BxO => x2
Blue has a dampening effect, bringing order to chaos and calming the intense emotional elements.
- BxG => x2
- GxB => x0.5
- MxB => x0.5
This also dampens energetic Yellow.
- YxB => x0.5

Neglecting its physical bounds leaves it vulnerable to the physical element Red. Also Blue is weak to dark magic (e.g. Purple), and Red has a very ritualistic/blood magic vibe (which will probably be unspoken in the game).
- RxB => x2

**Red**
Red is the architypical physical type.

Red's dogmatic nature grounds Magenta's whimsy.
- RxM => x2
- MxR => x0.5

**Magenta**
I want Magenta to be a fairly neutral type. It could be interesting to have it resist everything, except for Red. However, this would clash with Cyan being the defensive architype. I could give it resistances to the emotional/mental types (oblivious, it goes its own way) as well as another weakness tho.

# Offense/Defense Analysis
After filling out the type chart (see [[resists_explained#Matchups Explained|Matchups Explained]] for details), I did another analysis pass, paying special attention to Offensive/Defensive types. 

![[resistances_v2.png]]

|             | Offense       |                | Defense        |             |
| ----------- | ------------- | -------------- | -------------- | ----------- |
| **Element** | **Good (x2)** | **Bad (x0.5)** | **Good(x0.5)** | **Bad(x2)** |
| Blue        | 2             | 0              | 3              | 2           |
| Cyan        | 1             | 1              | 4              | 1           |
| Yellow      | 1             | 3              | 4              | 2           |
| Magenta     | 0             | 4              | 1              | 1           |
| Green       | 5             | 2              | 0              | 2           |
| Purple      | 2             | 3              | 1              | 4           |
| Red         | 2             | 1              | 1              | 1           |
| Orange      | 2             | 1              | 2              | 1           |
As a rule of thumb, I'd like each element to have more in its respective good column than respective bad (so offensive types should have col1 > col2, but col3 & col4 don't matter). 

As it stands now, the defensive types are pretty solid. Magenta is a little lacking, but I'm still on the fence about whether to give it 7* resists. The offensive types, however, could definitely use some attention.

I'd like to buff Magenta:
- B(~~Emotional~~Mental)xM(Oblivious) => x0.5
- G(Emotional)xM(Oblivious)=> x0.5
- C(~~Emotional~~Mental)xM(Oblivious) => x0.5
- OxM => x2

|             | Offense       |                | Defense        |             |
| ----------- | ------------- | -------------- | -------------- | ----------- |
| **Element** | **Good (x2)** | **Bad (x0.5)** | **Good(x0.5)** | **Bad(x2)** |
| Blue        | 2             | 0+1            | 3              | 2           |
| Cyan        | 1             | 1+1            | 4              | 1           |
| Yellow      | 1             | 3              | 4              | 2           |
| Magenta     | 0             | 4              | 1+3            | 1+1         |
| Green       | 5             | 2+1            | 0              | 2           |
| Purple      | 2             | 3              | 1              | 4           |
| Red         | 2             | 1              | 1              | 1           |
| Orange      | 2+1           | 1              | 1              | 2           |

After those changes, I'd like to buff Purple:
- PxY => x1
- PxR => x2

And make Red slightly more tanky:
- YxR => x0.5
- CxR => x0.5
- BxR => x0.5

|             | Offense       |                | Defense        |             |
| ----------- | ------------- | -------------- | -------------- | ----------- |
| **Element** | **Good (x2)** | **Bad (x0.5)** | **Good(x0.5)** | **Bad(x2)** |
| Blue        | 2             | 1+1            | 3              | 2           |
| Cyan        | 1             | 2+1            | 4              | 1           |
| Yellow      | 1             | 3+1            | 4-1            | 2           |
| Magenta     | 0             | 4              | 4              | 2           |
| Green       | 5             | 3              | 0              | 2           |
| Purple      | 2+1           | 3-1            | 1              | 4           |
| Red         | 2             | 1              | 1+3            | 1+1         |
| Orange      | 3             | 1              | 1              | 2           |

![[resistances_v3.png]]

# Final Analysis

| Category                                             | Number |
| ---------------------------------------------------- | ------ |
| Inert types (no transmutation or resistance)         | 17     |
| Transmutation only                                   | 11     |
| Resistance Only                                      | 13     |
| Both                                                 | 23     |
| Cycles (2 elements are supereffective to each other) | 2      |
# Post-Analysis
After not looking at this system for over a month, I'm going to analyze it once more, to determine whether it is worth pursuing.

The main angle I'm analyzing here is "how easy would this be to explain to the player, and for the player to internalize and use?"
## Theming
Blue(Astral, Water)
Purple(Astral, Dark)
Magenta(Glitter, Fairy)
Red(Blood, Plant)
Orange(Plastic, Fire)
Yellow(Air, Light)
Green(Nuclear, Poison)
Cyan(Ice, Steel)
## Matchups
~~B()xM() => x0.5~~ B(Mental)xM(Oblivious) => x0.5
B(Water)xR(Plant) => x0.5
B(Water)xO(Fire) => x2
B(Water)xG(Nuclear) => x2

P(Dark)xB(Astral) => x2
P(Dark)xP(Dark) => x2
P(Dark)xM(Whimsy) => x0.5
P()xR() => x2
P(Fear)xC(Stalwart) => x0.5

M(Emotional)xB(Calm) => x0.5
M(Whimsy)xP(Dark) => x0.5
M(Whimsy)xR(Blood) => x0.5
M(Emotional)xC(Stalwart) => x0.5

R(Plant)xB(Water) => x2
R(Blood)xM(Whimsy) => x2
~~R()xY() => x0.5~~ R(Physical)xY(Gaseous) => x0.5

O(Fire)xP(Dark) => x2
O()xM() => x2
~~O(Fire)xY(Air) => x0.5~~ O(Physical)xY(Gaseous) => x0.5
O(Fire)xC(Ice) => x2

Y()xB() => x0.5
Y(Light)xP(Dark) => x2
~~Y()xR() => x0.5~~ Y(Defensive)xR(Offensive Tank) => x0.5
~~Y()xY() => x0.5~~ Y(Physical)xY(Gaseous) => x0.5
Y(Air)xC(Ice) => x0.5

G(Nuclear)xB(Water) => x0.5
G(Offense)xP() => x2
~~G(Offense)xM(Defense) => x0.5~~ G(Emotional)xM(Oblivious) => x0.5
G(Offense)xR() => x2
G(Offense)xO() => x2
G(Offense)xY(Fragile) => x2
G(Offense)xG() => x2
G(Offense)xC() => x0.5

>[!note]
>A lot of Green's matchups have to do with it being an offensive type. It is resisted by every defensive type, except for Yellow (which is more of an 'evasive' type).

C(Stalwart)xM(Emotional) => x0.5
~~C()xR() => x0.5~~ C(Defensive)xR(Offensive Tank) => x0.5
C(Ice)xO(Fire) => x0.5
C(Ice)xY(Air) => x2

| Category                                                                                                       | Number           |
| -------------------------------------------------------------------------------------------------------------- | ---------------- |
| Simple: Matchup can be explained using simple type analogies (e.g. fire beats ice).                            | ~~14~~ 13        |
| Secondary: Matchup is explained using secondary analogies or attributes (e.g. Cyan resists emotional elements) | ~~14~~ ~~19~~ 21 |
| Non-obvious                                                                                                    | ~~9~~ ~~5~~ 3    |
>[!done]
>Using this data, I think the resistance system can be kept as-is and still be explained. However, it still might be somewhat difficult, as it doesn't quite translate as well as simpler type systems. 

## Non-Obvious
A lot of the 'non-obvious' category were probably added previously for balancing purposes, which makes me hesitate to remove them. 

For reference, the following were added as buffs:
- B(Emotional)xM(Oblivious) => x0.5
- BxR => x0.5
- PxR => x2
- ~~PxY => x1~~
- OxM => x2
- YxR => x0.5
- G(Emotional)xM(Oblivious)=> x0.5
- C(Emotional)xM(Oblivious) => x0.5
- CxR => x0.5

And here are the non-obvious:
- ~~B()xM() => x0.5
- ~~P()xR() => x2
- ~~O()xM() => x2
- ~~Y()xR() => x0.5
- ~~C()xR() => x0.5
- M()xB() => x0.5
- R()xY() => x0.5
- Y()xY() => x0.5

The crossed out ones are present in both lists, and therefore explained by this section's hypothesis. That leaves the following 3 non-obvious matchups:
- M()xB() => x0.5
- R()xY() => x0.5
- Y()xY() => x0.5

The original reasons given for these matchups are as follows:
- M(Emotional)xB(Calm) => x0.5
	- Blue has a dampening effect, bringing order to chaos and calming the intense emotional elements.
- Yellow is a very gaseous type, making it resistant to the other physical elements.
	- RxY => x0.5
	- YxY => x0.5 
	- ~~OxY => x0.5

Returning to the changes made for balancing:
- B()xM() => x0.5
- O()xM() => x2
- P()xR() => x2
- Y()xR() => x0.5
- C()xR() => x0.5

Like a defensive version of Green, I made Red resist all defensive types. It isn't weak to all offensive types, however (its neutral against Red and Orange).
- Y(Defensive)xR(Offensive) => x0.5
- C(Defensive)xR(Offensive) => x0.5

I made a mistake, which has been corrected in the notes above, labelling Blue as an emotional element.
- B(Mental)xM(Oblivious) => x0.5
This is fine, b/c Magenta resists all mental elements and the only other emotional element (Green).

This leaves the following unexplained:
- OxM
- PxR
# Improved Explanations
This will hopefully be an alternative way of viewing the chart, w/o too many changes. Most of the matchup explanations in the previous section use secondary attributes, like mental/emotional/physical or offense/defense. Hopefully these rules can be generalized.

![[resistances_v3.png]]

| Element | Defense/Offense | M/E/P     | Type 1  | Type 2    |
| ------- | --------------- | --------- | ------- | --------- |
| Blue    | Defense         | Mental    | Water   | Astral    |
| Purple  | Offense         | Mental    | Dark    | Astral    |
| Magenta | Defense         | Emotional | Fairy   |           |
| Red     | Offense         | Physical  | Plant   | Blood     |
| Orange  | Offense         | Physical  | Fire    | Synthetic |
| Yellow  | Defense         | Physical  | Air     | Light     |
| Green   | Offense         | Emotional | Nuclear | Poison    |
| Cyan    | Defense         | Mental    | Steel   | Ice       |
Blue resists all emotional elements.
Magenta lives in a world of its own, resisting mental and emotional elements.
Yellow is gaseous, resisting all physical elements.
Cyan is Stoic and Stalwart, so it resists the Emotional types.

***Blue***
B(Mental)xM(Oblivious) => x0.5
B(Water)xR(Plant) => x0.5
B(Water)xO(Fire) => x2
B(Water)xG(Nuclear) => x2

***Purple***
P(Dark)xB(Astral) => x2
P(Dark)xP(Dark) => x2
P(Dark)xM(Whimsy) => x0.5
P()xR() => x2
P(Fear)xC(Stalwart) => x0.5

***Magenta***
M(Emotional)xB(Calm) => x0.5
M(Whimsy)xP(Dark) => x0.5
M(Whimsy)xR(Blood) => x0.5
M(Emotional)xC(Stalwart) => x0.5

***Red***
R(Plant)xB(Water) => x2
R(Blood)xM(Whimsy) => x2
R(Physical)xY(Gaseous) => x0.5

***Orange***
O(Fire)xP(Dark) => x2
O(Synthetic)xM() => x2
O(Fire)xY(Air) => x0.5
O(Fire)xC(Ice) => x2

***Yellow***
Y()xB() => x0.5
Y(Light)xP(Dark) => x2
Y(Defensive)xR(Offensive Tank) => x0.5
Y(Physical)xY(Gaseous) => x0.5
Y(Air)xC(Ice) => x0.5

***Green***
G(Nuclear)xB(Water) => x0.5
G(Hyper-Offense)xP(Offense) => x2
G(Emotional)xM(Oblivious) => x0.5
G(Hyper-Offense)xR(Offense) => x2
G(Hyper-Offense)xO(Offense) => x2
G(Hyper-Offense)xY(Fragile) => x2
G(Hyper-Offense)xG(Offense) => x2
G()xC() => x0.5

***Cyan***
C(Stalwart)xM(Emotional) => x0.5
C(Defensive)xR(Offensive Tank) => x0.5
C(Ice)xO(Fire) => x0.5
C(Ice)xY(Air) => x2