@tool
extends Control

var MatchupItem
var vbox

func _ready():
	MatchupItem = preload("res://addons/matchupmanager/components/matchup_item.tscn")
	vbox = get_node("VBoxContainer/ScrollContainer/VBoxContainer")

	ElementManager.ForceLoad()
	for matchup in ElementManager.GetAllMatchups():
		var item = MatchupItem.instantiate()
		item.set_colors(matchup[0], matchup[1], matchup[2])
		vbox.add_child(item)

		item.buff_selected.connect(func(index):
			ElementManager.SetSideEffectFor(matchup[0], matchup[1], index, true))
		item.debuff_selected.connect(func(index):
			ElementManager.SetSideEffectFor(matchup[0], matchup[1], index, false))


