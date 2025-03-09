#discussion 
>[!note]
>The physics based attempt of this has proven inefficient. This page is a discussion on how to better design it.

# Basic Requirements
- Laser PuzzleBlock components should function on a grid basis.
	- Moveable components should snap to grid.
	- Laser beams should move along x or z axis.

Emitter:
- Sends out laser in straight line.
- Gives laser a set of properties. These properties should have significant (complete?) overlap with the overworld spell system.
	- Elemental.
	- Stasis.
	- Destroy.

Receiver:
- Has an elemental type attribute (`element`).
- Has 3 states: `valid`, `invalid`, `off`.
	- No laser mean `state => off`.
	- If `element == Blank`, `state => valid`
	- If `laser.element == self.element`, `state => valid`.
	- If `laser.element != self.element`, `state => invalid`.

Mirror:
- Bends input laser 90deg.
- Has an elemental type attribute (`element`).
	- If `element == Blank`, `laser.element` remains unchanged.
	- If `element * laser.element => Blank`, `laser.element` remains unchanged.
	- Otherwise, `laser.element` is changed to match the transmutation product.

Intermediary Components (e.g. mirrors):
- When a Laser hits an intermediary component, it ends and a new Laser is created.
# Laser Anatomy
Lasers will use physics layer 4 and 5.
- Layer 4 is for typical laser PuzzleBlocks.
- Layer 5 is for objects that absorb/block lasers, but don't otherwise interact.
An `SubEmitter` uses a `RayCast3D` for detection.
A `SubReceiver` checks for these raycasts.
~~If two raycasts cross, they generate a `Disruption`, ending both beams.~~
	At the moment, this isn't possible. Adding a collider caused the mesh to disappear. This may be a solvable problem, but I don't think its a priority.

These components are not `PuzzleBlocks`, they should be attached as subcomponents.
