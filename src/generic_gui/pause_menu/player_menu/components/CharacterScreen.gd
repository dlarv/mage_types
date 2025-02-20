extends Control

var _actor: BattleActor

func setup(actor: BattleActor) -> void:
	_actor = actor

	%Name_Label.text = actor.name

	if actor.elemental_bias.is_blank():
		%Bias_Label.hide()
		%Bias_ElementIcon.hide()
	else:
		%Bias_Label.show()
		%Bias_ElementIcon.show()
		%Bias_ElementIcon.element = actor.elemental_bias
	
	%Primary.element = actor.element1
	%Secondary.element = actor.element2
	actor.element_changed.connect(_on_element_changed)


func _on_element_changed(id: int, element: ElementalType) -> void:
	if id == 0:
		%Primary.element = element
	else:
		%Secondary.element = element
