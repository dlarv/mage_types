@tool
extends MagiClay

@export var puzzle_block: PuzzleBlock


func _ready() -> void:
	super._ready()
	element_changed.connect(puzzle_block.set_element)
	element_changed.emit(element)
