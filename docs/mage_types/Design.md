# Battle System
## Adding an Attack
## Adding a new Status Condition
## Adding a new Battle Item
## Adding a new Opponent Controller

# Characters
## Scene Setup
1. Add DialogueBox to scene.
2. Add VendorMenu to scene.
3. Create new dialog tree resource and add it to `DialogBox.data`.
4. Connect `Player` signals to `OverworldConnector`.
## Creating an NPC
1. Add NPC to scene.
2. Add CollisionShape3D, MeshInstance3D, etc.
3. Add applicable actors.
### Add a StoryActor
1. [[#Creating an NPC|Create NPC]].
2. Add StoryActor.
3. Add one or more new dialog tree to scene's dialog tree resource.
4. Set `StoryActor.dialog_ids` to a list of the ids created during step 3.
5. Set `StoryActor.current_id` to the index of whichever id to use first.
### Creating a Wild Enemy
1. [[#Creating an NPC|Create NPC]].
2. Add NPC to "wild_enemies" group. 
	1. If the player collides with 2 enemies at once, or the original enemy isn't removed from scene immediately, this will prevent it from immediately starting a new battle.
3. Add EnemyActor.
	1. Fill out `team` w/ BattleActors.
	2. Add an `OpponentController`.
### Creating an Aggressive StoryActor
>[!note]
>This doesn't entail a 'mean' StoryActor, just that one of its dialog branches ends w/ the "battle_started" signal.
1. [[#Creating an NPC|Create NPC]].
2. Add EnemyActor
	1. Fill out `team` w/ BattleActors.
	2. Add an `OpponentController`.
3. Add StoryActor.
### Creating a Vendor
1. [[#Creating an NPC|Create NPC]].
2. Add list of items, either manually or using the 'Add Item' field in the inspector.
	1. Dragging an item will automatically create the associated wrapper class.
	2. You just need to fill out the `cost` field.
3. \*If Vendor has no StoryActor, the following should be added to the scene's dialog tree:
	1. Start Node w/ ID="VENDOR_MAIN".
	2. Dialogue Node w/ generic text.
	3. Signal Node w/ signalname="menu_opened".
4. If Vendor has a StoryActor, make sure one of its dialog branches ends w/ a "menu_opened" signal.

\*All solo VendorActors in this scene will use this generic dialog.