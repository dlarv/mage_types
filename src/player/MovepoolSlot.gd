@tool
extends Resource
class_name MovepoolSlot

@export var level_lock: int = -1
@export var scroll: SpellScroll

var spell: Attack:
	get:
		if scroll == null: return null
		return scroll.spell

var quantity: int = 0

func _ready() -> void:
	if not Engine.is_editor_hint(): 
		pass
