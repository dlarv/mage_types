@tool
extends Resource
class_name MovepoolSlot

@export
var level_lock: int = -1
@export
var scroll: SpellScroll

var spell:
	get:
		if scroll == null: return null
		return scroll.spell

var quantity:
	get:
		if scroll == null: return -1
		return scroll.quantity
