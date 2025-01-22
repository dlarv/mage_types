# General Assets
**Geysers**: Consists of 2 parts: 
- A base, which can be targeted by *Stasis* and *Catalyst*.
- A stream, which can push and block the player.
Hitting the base with *Stasis* will pause the stream.
Using *Catalyst* will change the composition of the stream. This will mostly change its height, but a few elements will have secondary effects.
- Yellow will be the default composition and will have the biggest stream.
- Red will have a similarly large stream, but also be able to push objects.

**Large Boulder**: Can be targeted by *Catalyst* or *Stasis*. Weight depends on elemental composition:
B > C > G     Heavy
R > M > O    Medium
P > Y            Light
Heavy cannot be moved.
Medium can be moved by strong **geysers**.
Light can be moved by player.

*Stasis* prevents boulder from being moved.
*Catalyst* will change its composition.

**Small boulder**: Can be moved by player.
*Stasis* prevents boulder from being moved.
*Catalyst* will change its composition.

# Puzzle Blocks
## General 
**Elemental Plate**: Placing a boulder/etc of matching composition on top will emit a success signal. 
- Small: If element is Blank, these can be triggered by the player.
- Large: These can only be triggered by rocks/boulders.
**Wire**: Lights up when a success signal is emitted.
**Door**: Unlocks permanently upon receiving a success signal.
- Should have a `solved` signal it emits when the room is loaded, telling all `PuzzleBlocks` to turn off.
**Delay**: Starts a timer once it receives an `on` signal. If timer elapses without receiving an `off` signal, it emits its own `on`.
**Button**: Sends signal when interacted with by player.
## Laser beams
~~**Beam**: Shoots a laser with a particular element/color.~~
**Stasis Beam**: Applies stasis effect to whatever it hits. Has no elemental composition.
**Catalyst Beam**: Shoots a laser with a particular element/color. Acts like the *Catalyst* spell on contact.
**Clear Receiver**: Emits a success signal when hit by any beam.
**Colored Receiver**: Emits a success signal when hit by a specific color of beam.
**Clear Mirror**: Change the direction of the beam.
**Colored Mirror**: Like mirror, but also transmutes the beam.

Catalyst beams get transmuted when they cross.
Catalyst beams cannot cross Stasis beams.