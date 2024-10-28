@tool
extends Button

signal pressed2(isEmpty, index)

var index: int
var spell: Attack = null


func _enter_tree():
	pressed.connect(func(): pressed2.emit(spell == null, index))


func set_spell(attack: Attack, index: int) -> void:
	self.index = index
	spell = attack
	if attack == null: 
		text = ""
	else:
		text = spell.name


func clear() -> void:
	spell = null
	text = ""

