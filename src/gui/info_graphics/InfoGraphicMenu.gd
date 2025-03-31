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

#virtual
func prev_screen() -> void: 
	current_tab = max(0, current_tab - 1)


func _on_hidden() -> void:
	info_graphic_closed.emit()


