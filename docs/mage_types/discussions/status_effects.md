# v1
 
| Name       | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| Poison     | Damage over time.                                                   |
| Blocking   | Prevents the next damage the actor would take.                      |
| Dissonance | Prevents Primary + Secondary transmutations.                        |
| Stasis     | Prevents Attack + (Primary \| Secondary) transmutations.            |
| Healing    | Healing over time.                                                  |
| Phobia     | Damages the actor everytime they transmute into a specific element. |
| Philia*    | Heals the actor everytime they transmute into a specific element.   |
| Flinched** | Skips the actor's next turn.                                        |
\*Philia: I don't like this name.
\*\*Flinched: The v0.1.0 build of the battle ui does not easily support this. I might remove it from at least the demo version.
# Proposal v2
Each element will have 3 status effects:
- 1 phobia
- 1 philia
- Other

| Element | Effect    | Description                                 |
| ------- | --------- | ------------------------------------------- |
| Blue    | Stasis*   | Prevents transmutations.                    |
| Purple  | Flinched  | Skips turn.                                 |
| Magenta | Healing   | Healing over time.                          |
| Red     | Leech     | Damages opponent and heals team.            |
| Orange  | Confusion | Randomizes RGB value of elements.           |
| Yellow  | Airy      | Evasion boost.                              |
| Green   | Poison    | Damage over time.                           |
| Cyan    | Blocking  | Prevents the next attack from doing damage. |
\*Stasis and dissonance will be combined.
# Brainstorm
- Red
	- Leech
	- Large stat boost upfront, damage over time after awhile. Like worse gambit.
- Orange
- Yellow
	- Evasion boost.