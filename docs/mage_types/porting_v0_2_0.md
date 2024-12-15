What needs to change going from v0.1.0 -> v0.2.0 
- [x] Remove projectile system.
- [ ] Modify AffinityManager to only use RGB pools.
	- [ ] Modify attacks to use new affinity costs.
- [ ] Change battle gui to support 3D models instead of sprites.
- [x] Move ElementalEffect.Element into Effect.Element.
- [ ] Create Generic Overworld Battle Connection class.
- [x] Refactor ElementManager class: Hardcode values that won't change.
- [x] Have attacks take resistances into account.
- [x] Refactor Element info panels.
- [ ] Have battle system use dialog nodes addons, or at least their style.
- [ ] Add new OpponentController methods: [[Technical#Opponent Controllers|AI]].
# Bugs
- [ ] Actor formatter is broken (if attack is null, it fails).
- [ ] Message displayed when actor is inflicted with phobia just says "Blank".