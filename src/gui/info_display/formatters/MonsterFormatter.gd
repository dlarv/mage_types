extends Formatter

const ActorFormatter := preload("actor_formatter.tscn")


func display(monsters: Variant, limitInfo:=false) -> void:
	super.display(monsters)
	for child in $TabContainer.get_children(): $TabContainer.remove_child(child)

	if len(monsters) == 1: 
		var formatter := ActorFormatter.instantiate()
		$TabContainer.add_child(formatter)
		$TabContainer.tabs_visible = false
		formatter.display(monsters[0])
		return
	$TabContainer.tabs_visible = true

	for monster: BattleActor in monsters:
		var formatter := ActorFormatter.instantiate()
		formatter.name = monster.name
		$TabContainer.add_child(formatter)
	$TabContainer.get_child(0).display(monsters[0])
