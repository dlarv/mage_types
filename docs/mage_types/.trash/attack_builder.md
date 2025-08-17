he UI would have to allow the user to select the following fields: 
- Battle Action
	- Name: string
	- \*Animation: PackedScene
	- Element: ElementalType
	- Priority: int
	- Range: { Melee, Ranged, Status }
	- Target: { Self, Ally, Allies, Enemy, Enemies }
	- Details: string
- Attack
	- Cost: int
	- Effects: _Effect_\[]
		- Target: { User, Target }
		- Chance: percentage
		- \*AttackEffect: _AttackEffect_
\*These will have to give the user limited access to the filesystem.

In addon mode, the user should be given the option to save their new move to the filesystem.
In sandbox mode, the user should be given a spellscroll containing their new move.

![[attack_builder.drawio.png]]

# Effect Builder
![[attack_effects#List of Attack Effects (v0.1.0)]]


# Additional Fields
- Strength
	- Damage (int)
	- Instant Health Change (float)
	- Strike (int)
	- Draining Damage (int)
	- Generate Affinity (int)
- Element (ElementalType):
	- Phobia
	- Philia
	- Transmutate
	- Strike
	- Generate Affinity
- Allow Overflow (bool):
	- Draining Damage
	- Instant Health Change
- Stat (Stat):
	- Stat Change
- Stack(int):
	- Stat Change
- Id(int):
	- Transmutate
- Heal Percent (float):
	- Draining Damage
- Min/Max (float/float):
	- Random Phobia
	- Strike
- Type (Enum):
	- Strike