extends PuzzleBlock

func set_stasis(val=null) -> void:
	super.set_stasis(val)

	if in_stasis:
		on.emit(self)
	else:
		off.emit(self)
