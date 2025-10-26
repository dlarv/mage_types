extends "_Bubble.gd"

# data: ActorTurnData
func setup(data: Variant) -> void:
	$MarginContainer/HBoxContainer/RichTextLabel.text = _get_affinity_text(data.effectiveness)


func _get_affinity_text(affinity: float) -> String:
	if affinity <= Attack.POOR_AFFINITY_THRESHOLD:
		return "[color=red]POOR[/color]"
	elif affinity <= Attack.WEAK_AFFINITY_THRESHOLD:
		return "[color=orange]WEAK[/color]"
	elif affinity <= Attack.GOOD_AFFINITY_THRESHOLD:
		return "[color=light_green]GOOD[/color]"
	else:
		return "[color=green]GREAT[/color]"
