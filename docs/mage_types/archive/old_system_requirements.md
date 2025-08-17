*This used to be part of [[Background]], but its archived as most of its info is irrelevant or discussed elsewhere.*
# 2. Battle System
## Basic Requirements
- Turn based.
- The player will have 1-3 actor under their control, but could have more at different times.
- The opponents will have 1+ actor under their control.
- Every turn, each actor has 1 action.
	- An action can be either an attack or an item.
	- The player also has the option to run away.
- Each actor can have a list of status effects and stat changes effecting them.
- After all actors have selected their move, their moves are resolved in priority-speed-random order.
- When an attack is used, resolve any applicable transmutations.
- At the end of turn, resolve any status conditions and decrement any related counters.
## 2D vs 3D
In v0.1.0, the battle UI was completed implemented in 2D. However, it might make more sense to use 3D, so that I can resuse assets.
## Stats
Each combatant will have the following basic stats:
- Melee Attack
- Ranged Attack
- Melee Defense
- Ranged Defense
- Speed

There's also 2 stats, typically hidden in other similar styles of game:
- Accuracy
- Evasion
If present, I would like the ability to view these stats, at least in debug mode.
## Status Effects
![[status_effects#Proposal v2]]
# 3. Overworld System
## Transmutation Puzzles
In v0.1.0, the player had the ability to transmute certain objects at any time. This system will be removed, with the possibility of a more limited version being introduced in the future.
## Overworld Spells/Temple Mechanics
For discussion of temples, see [[Design#Dungeons|here]].
For discussion of how these should be implemented, see [[Technical#Overworld Spells|here]].
Discussion of lock and key philosophy: .

In this [[overworld_spells|document]], I discuss a simpler version of the Overworld spells, treating it more like a straightforward lock-and-key system.
Each spell should only be design to remove a specific type of obstacle, with more complex synergies being more of a stretch goal.

It would be best if the spells also tied into the preexisting systems:
1. Resistances & Weaknesses
2. Affinity (Offensive/Defensive)
3. Transmutations
### General Mechanics
Each spell a player has will be accessed thru a hotkey. Targeting should generally work based on the direction the player is facing or on the spot the player is standing on.
### List of Overworld Spells
- **Stasis**([[Design#Blue Temple|Blue Temple]]): Prevents an object from transmuting or moving.
- **Destroy**\*(Purple Temple?): Breaks an object, based on the resistance system(1).
- **Catalyst**([[Design#Sunset Temple|Sunset Temple]]): Forces a transmutation to happen.
- **Vines**([[Design#Red Temple|Red Temple]]): Grows vines out of a patch of clay.
- **Tunnel**\*:([[Design#Abandoned Temple|Abandoned (Green) Temple]]) Fast travel between two points.
\*WIP name.
#### Stasis
Player selects an adjacent object. This object cannot be transmuted. If object is moving (e.g. an automated platform or enemy sprite), it stops until effect wears out. 
#### Destroy
Player channels element found at their feet. A projectile of this type is launched in a straight line. Upon collision with a _Cracked Clay Obstacle_: 
- If `object.element` is weak to `projectile.element` both projectile and object are destroyed.
- If `object.element` resists `projectile.element`, projectile is destroyed.
- If `object.element` is neutral to `projectile.element`, projectile bounces.
#### Vines
Player channels energy, encouraging the growth of nearby flora. When used on _Clay Terrain_, grow one of the following formations:
- Bridge: Creates a horizontal platform.
- Wall: Grows climbable section on nearby wall.
- Shoot: Grows a climbable, vertical platform.
#### Catalyst
Similar to destroy, player channels element found at their feet. A projectile of this type is launched in a straight line. Upon collision with a _Clay Obstacle_:
- If a transmutation exists, transmute object and destroy projectile.
- Otherwise, projectile bounces.
#### Tunnel
When used on _Clay Terrain_:
- Some _Clay Terrain_ contains the entrance to a secret room/area. If this is one such instance, open a doorway to area.
- Otherwise, creates a tunnel between nearest `terrain.element`.
### Other Ideas
Other than claymation, these artforms could serve as inspiration for overworld spells.
- Origami
- Sewing
	- Needle and thread
	- Knitting
- Paint

To avoid making this game more convoluted, only one of these mechanics should be implemented as overworld spells, if any. 

Particularly, I like the origami idea best. I think it could make an interesting late-game addition.