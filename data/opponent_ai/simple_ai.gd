extends OpponentControl

func _calculate_move(actor: BattleActor.Fighter, team: Array, other: BattleActor.Fighter):
	attack_selected.emit(actor.attacks[0], ID)
