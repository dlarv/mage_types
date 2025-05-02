extends Menu
## Displays a slideshow of 1+ slides. Closes once player skips last slide or presses escape.

signal info_graphic_closed()

#virtual
func next_screen() -> void: 
	var index := current_tab + 1
	if index == get_tab_count():
		hide()
		info_graphic_closed.emit()
		return

	current_tab = index
	_check_for_video_player()

#virtual
func prev_screen() -> void: 
	current_tab = max(0, current_tab - 1)
	_check_for_video_player()


func _on_hidden() -> void:
	info_graphic_closed.emit()
	if _video_player:
		_video_player.stop()
		_video_player = null

func _draw() -> void:
	_check_for_video_player()
