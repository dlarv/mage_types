@tool
extends Node3D

@export var decal: Decal
@export var from: PuzzleBlock
@export var to: PuzzleBlock

func _ready() -> void:
	if from != null:
		from.on.connect(_on_block_on)
	if to != null:
		to.off.connect(_on_block_off)

func _on_block_on(block: PuzzleBlock) -> void:
	pass

func _on_block_off(block: PuzzleBlock) -> void:
	pass


func _on_child_entered_tree(node:Node) -> void:
	if node is Marker3D:
		var d := decal.duplicate() 
		d.show()
		node.add_child(d)


