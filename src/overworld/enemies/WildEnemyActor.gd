extends "res://src/overworld/characters/Npc.gd"

@export var ball: PackedScene
var _spheres := 0

func setup(team: Array, controller: OpponentController) -> void:
	for actor in team:
		_add_new_gradient_sprite(actor)
	
	$EnemyActor.ai = controller
	$EnemyActor.team = team

func _add_new_gradient_sprite(actor: BattleActor) -> void:
	_spheres += 1
	var mesh = ball.instantiate()
	mesh.setup(actor)

	mesh.position.y = 1 * _spheres
	add_child(mesh)

# Override
func react(e: ElementalType, randVal:=-2) -> bool:
	for actor in $EnemyActor.team:
		var e1 = ElementManager.get_matchup(actor.element1, e)
		if e1:
			actor.set_element(0, e1)

		var e2 = ElementManager.get_matchup(actor.element2, e)
		if e2:
			actor.set_element(0, e2)

	return true
