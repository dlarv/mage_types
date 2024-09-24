@tool
extends Item 
class_name SpellScroll

@export
var spell: Attack
@export_range(0, 1)
var quantity: int = 0
