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
# Matchup Expansion
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
- B(Emotional)xM(Oblivious) => x0.5
- G(Emotional)xM(Oblivious)=> x0.5
- C(Emotional)xM(Oblivious) => x0.5
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

