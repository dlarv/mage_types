#discussion #deprecated
Initially, this wasn't part of the system. However, I enjoy this aspect of other type systems and so decided to include it as well. 

> [!note]
> In lore, Red, Green, and Blue are not fundamental building blocks (like a Cyan object is not composed of Green and Blue atoms). However, this is a useful way of thinking about it when considering resistances/weaknesses.

The foundational principle is that an element is weak to the primary color(s) not present in itself and resistant to the ones that are.

|     | R   | G   | B   |
| --- | --- | --- | --- |
| R   | --- | +++ | +++ |
| G   | +++ | --- | +++ |
| B   | +++ | +++ | --- |
> Where the first column is the attacking type
> and the first row is defending.
> Where +++ denotes a weakness and --- a resistance.

So R, G, B all have 2 weaknesses and 1 resistance (so far).

When Cyan is hit with a Blue attack, the resist and weakness cancel out, leaving it neutral to the attack. However, if Cyan is hit with Red, it is super effective!

>[!question]
>Should the supereffective modifier cap out at x2 or be unbounded?
>e.g.
>Cyan + Red => x2
>or
>Cyan + Red => x4

>[!note] Purple and Orange
>For the sake of these calculations, 
>- Purple = Magenta 
>- Orange = Yellow.
# The Basic Algorithm
Formalized, the process looks like this:
1. Consider E and D, which are elements represented as sets of RGB.
	1. E.g. Cyan = {B, G}, Blue = {B}
2. Let ExD denote that a mage of type E is hit with an attack of type D.
	1. DEFENSExATTACK
3. T = Intersection(E, D)
	1. Consider the venn diagram between E and D. These are the elements in both sets.
	2. BxC = {B}x{B, G} => T = {B}
4. S = Cartesian(E, D) 
	1. E.g. every pair of elements.
	2. If Length(T) > 0, one of these pairs is of the form {x,x}. These represent resistances.
5. U = Length(S) - Length(T), if Length(S)>0 else 1/2.
6. V = Length(T), if Length(T)>0 else 2.
7. Matchup = ${1 \over 2}V * 2 * U$
8. Matchup' = ${U \over V}$
	1. If Length(T) or Length(S) = 0, they both become 1/2.
### Conclusion
Because of symmetries in the color chart, a mage's resistances and weaknesses can be summarized as follows:
- P1 x P1 => x0.5 
- P1 x P2 => x2
- S1 x S1 => x1
- P1 x S1
	- If P1 and S1 share an subelement=> x1
	- Otherwise => x4
- S1 x S2 => x3
Where:
P = Primary Color = {R, G, B}
S = Secondary Color = {P, M, O, Y, C}

[[resistances_v1_proofs|Click here to see where these numbers came from.]]

>[!question] Potential Overrides
>There are three potential changes to this system, which would likely be implemented as hardcoded overrides:
>- P1 x P2 => ~~x4~~ =>x2
>- S1 x S1 => ~~x1~~ => x0.5
>- S1 x S2 => ~~x3~~ => x2
