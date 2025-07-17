extends TabContainer
class_name Menu

var _video_player: VideoStreamPlayer

#virtual
func next_screen() -> void: 
	current_tab = (current_tab + 1) % get_tab_count()
	_check_for_video_player()

#virtual
func prev_screen() -> void: 
	var index = (current_tab - 1)
	if index < 0:
		index = get_tab_count() - 1
	current_tab = index
	_check_for_video_player()

func _check_for_video_player() -> void:
	if _video_player:
		_video_player.stop()
		_video_player = null
	_video_player = get_children()[current_tab].find_child("VideoStreamPlayer")
	if _video_player:
		_video_player.play()


# Virtual
func reload() -> void: pass
