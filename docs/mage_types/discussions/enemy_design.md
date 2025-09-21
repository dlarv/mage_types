#discussion 

Requirements:
- Sense player position
- Exhibit behavior based on player proximity
	- Should be defined by child of `WildEnemyActor` for modularity
- Play animations based on current state
- Initiate battle when player comes in contact

Components
- StateMachine: Determines enemies next target position and what animations to play
	- Different behavior types should inherit from abstract class
- Model
	- AnimationPlayer
- MagiClay/Transmutation Manager
- PhysicsObject: Manage collisions and movement