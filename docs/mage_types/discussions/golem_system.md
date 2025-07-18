>[!note]
>For right now I'm not going to include the Golem spell. I think it should be included somehow in the final game, I'm just not sure what that'll look like.


- Golems will be MagiClay constructs which can be given basic instructions by the player
- At some point, the player should have the ability to create battle golems
-  Golems can execute basic instructions
-  Golems can be transmuted by lasers
-  Golems can be spawned in by player
-  Golem debug editor
	-  Allow player to set stats via slider
	-  Allow player to set primary and secondary types
	-  Allow player to assign spells
-  Allow player to given golems a set of instructions (max instruction amount can be updated)
-  Golems will get 2 ability slots (stasis, lifting objects, etc). These will be assigned in the creation menu and accessed via the instruction editor.
-  Different golem types should have different abilities
-  Golems should have a health bar
-  Upon dying, golems should leave a permanent pile of clay
	-  Player should be able to collect any spell beads/items/etc they equipped onto the golem

Future Additions
- [ ] Golem QOL
	- Areas with golem puzzles should have checkered floors
		- [ ] Checkered clay shader created
	- [ ] Ability to reorder instructions
	- [ ] Allow player to define golem's path by drawing on the map
	- [ ] When placing golem, make model transparent
	- [ ] When placing golem, snap to grid
	- [ ] When placing golem, allow player to rotate
	- [ ] Golem player editor
		- [ ] Golem's type is determined via same means as Catalyst spell
			- [ ] If player is not standing on MagiClay, they cannot spawn golem
		- [ ] Add maximum number of instructions
- [ ] Create fire and haze obstacles
- [ ] Give player ability to create battle golems
- [ ] Golems should have a health bar
- [ ] Complex properties
	- [ ] Magenta will bounce player?
		- This can be done by modifying a value in `Golem._push_object()`
	- [ ] Purple can walk up walls?
	- [ ] Orange can transmute itself?
- [ ] Grab draggable 
	- [ ] Maybe golem will grab any draggable that comes across its path? Maybe limit this based on golem's weight vs draggable's.
- [ ] Drop draggable (upon death?) Mb if golem isn't holding anything it'll work like a no-op.
- [ ] Channel MagiClayTerrain (changes composition of golem)
	- Lasers transmute, channeling straight up changes
- [ ] Player will have golem sets (arms, legs, torso, head) that they can mix and match
	- [ ] These will be used to determine stats/etc
- [ ] Add instruction budget to limit use of strong commands
- [x] Golems can execute basic instructions
	- [x] Walk
		- [x] Ensure golem is moving set amount of space with each step
	- [x] Turn
	- [x] Wait
	- [x] Goto
	- [x] ~~Goback~~ Again 
- [x] Golems can be transmuted by lasers
- [x] Golem can be hit with stasis to pause it
- [x] Golems can be spawned in by player
	- [x] Golem debug editor
		- [x] Allow player to set primary and secondary types
	- [x] Allow player to given golems a set of instructions (max instruction amount can be updated)
		- [x] Add ability to remove instructions 
### Golem Instructions
- Walk: num steps
- Turn: degrees
- Wait: seconds
- Goto: line

1. Player selects options from `InstructionPicker`.
2. `InstructionPicker` passes String to `GolemInstructionManager`.
3. `GolemInstructionManager` appends button to scroller.
4. Player selects value inside of button.
5. Player presses "Finish" button.
6. Instructions compiled into dictionary form.
7. Golem is passed to player.
8. Player is allowed to set golem down in their immediate vicinity.
### Golem Elemental Properties
Blue golems should be immune to water.
Purple golems can move thru shadow obstacle? (Haze?)
Magenta ...
Red golems can be ridden by the player
Orange golem can move thru fire obstacles
Yellow golems aren't affected by gravity
Green ...
Cyan ...