extends TabContainer
class_name Menu

#virtual
func next_screen() -> void: 
	current_tab = (current_tab + 1) % get_tab_count()

#virtual
func prev_screen() -> void: 
	var index = (current_tab - 1)
	if index < 0:
		index = get_tab_count() - 1
	current_tab = index

