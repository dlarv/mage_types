# Lasers
- Emitter: Shoots elemental laser in straight line
	- Draggable
- Mirror: Reflects laser, transmuting it if applicable
	- Rotating
	- Draggable
- Receiver: Unlocks when hit with correct elemental laser
	- Hidden
- Laser Redirect: Takes 1-2 laser inputs thru the sides, mixes them, and emits laser out front
- Lens: Like a mirror, but doesn't reflect laser
	- One Way: can be used to prevent lasers from doubling back on themselves
- Bridge: Once laser beam has been broken, turns itself off. Designed to somewhat resemble the arrows on the *Transmutation Map*
# Catalyst Devices
- Catalyst Device: Sets element of any MagiClay connected to its `element_changed` signal
	- Laser Activated
- Catalyst Platform: Sets element of any MagiClay resting on top of it
- #todo Catalyst Monolith: Sets element of all MagiClay w/in radius of effect
# Lockables
- Chest
- Gate
	- Environmental Door: Uses CSG to meld into environment
	- Key Gate: Player can interact with it. If they have correct key in inventory, gate unlocks
# Moving Parts
- Gear: turns everytime it receives a signal
- Piston: Moves up and down everytime it receives a signal
	- Mirror: Body is mirror which can reflect & transmute lasers
	- Path: Several pistons in sequence. Only one is in up position at any time
- Rails: When given a non-`Marker3D` child, it will move it between 2 points everytime it receives signal
# Empties
*They technically don't need a model to function, as they are mostly background elements*
- And Gate
- Or Gate
- Flipflop
- Mapper: Maps the `on`, `off`, and `invalid_off` signals of its input PuzzleBlock to one of those values (e.g. map input.off onto input.invalid_off, set all 3 signals to on, etc)
- OrdererdLock: Takes an ordered list of PuzzleBlocks, only unlocks when those PuzzleBlocks unlock in that order
- Pulser: Emits `on` signal on a repeating time interval
- Rotator: Rotates when it receives `on` signal
# Interactables
- Button
- Reset: Resets elements and positions of all MagiClay connected to it. Interfaces with `Chunk` to connect itself to all MagiClay in that `Chunk`. Only resets positions of blocks in array `Reset.reset_positions_of`
- Stasis Target: Emits signal when hit with Stasis `OverworldSpell`
- Wire: Lights up to show puzzle block is active. Can be used to show how different blocks are connected
- Geyser: Pushes player and other physics objects. Different elements have different geyser heights. Only Yellow geysers can be entered freely
# Misc
- Pressure Plates
- Indicator: Lights up to show which signal puzzle block is emitting (on/off/invalid_off)
- Relay: Once unlocked, can only be unlocked by `invalid_off`
- Delay: input puzzleblock must remain in on position for set time interval before this block unlocks
- Timer: Unlocks after receiving on signal, locks after set time interval
- 