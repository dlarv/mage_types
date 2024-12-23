#  v0.1.0 -> v0.2.0 
- [ ] Change battle gui to support 3D models instead of sprites.
- [ ] ~~Have battle system use dialog nodes addons, or at least their style.
- [x] Add new OpponentController methods: [[Technical#Opponent Controllers|AI]].
- [x] Modify AffinityManager to only use RGB pools.
	- [x] Modify attacks to use new affinity costs.
- [x] Remove projectile system.
- [x] Move ElementalEffect.Element into Effect.Element.
- [x] Create Generic Overworld Battle Connection class.
- [x] Refactor ElementManager class: Hardcode values that won't change.
- [x] Have attacks take resistances into account.
- [x] Refactor Element info panels.
# Demo v0.2.0+
- [x] Battle 3-state button: Combine info and target selection states into one.
- [ ] Design demo area.
	- [ ] Mini-bosses.
	- [ ] Puzzles.
	- [ ] Setpieces.
- [ ] Write demo story and tutorial.
- [x] Attack builder addon.
	- [ ] Sandbox area.
- [ ] Texture world.
- [ ] Music/audio.
- [ ] Animations.
# Bugs
- [ ] Actor formatter is broken (if attack is null, it fails).
- [ ] Message displayed when actor is inflicted with phobia just says "Blank".
