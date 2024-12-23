@tool
extends Control

@export var path := "res://data/battle_system/battle_actions/attacks/attack_builder"

@export var EffectSlotButton: PackedScene
@export var animations: Array[PackedScene]
@export var effects_scroller: VBoxContainer
@export var _animation_option_button: OptionButton
@export var _details_text_box: TextEdit

var _attack: Attack = Attack.new()

func _enter_tree():
	_animation_option_button.clear()
	for animation in animations:
		_animation_option_button.add_item(animation.resource_path.split("/")[-1].split(".")[0])
	
	default_attack()

func _exit_tree():
	_animation_option_button.clear()

func default_attack() -> void:
	_attack = Attack.new()
	_attack.animation = animations[0]

func _on_save_button_pressed() -> void:
	_attack.effects = []
	for effect in effects_scroller.get_children():
		_attack.effects.append(effect.get_effect())

	if Engine.is_editor_hint():
		# Save attack to fs.
		print("Saving to fs...")
		var err := ResourceSaver.save(_attack, "%s/%s.tres" % [ path, _attack.name ])
		if err != OK:
			print("Error: " + error_string(err))
	else:
		# Create SpellScroll and give it to player.
		print("Creating spell scroll...")
		var err := ResourceSaver.save(_attack, "%s/%s.tres" % [ path, _attack.name ])
		if err != OK:
			print("Error: " + error_string(err))


func _on_details_text_changed() -> void:
	_attack.details = _details_text_box.text


func _on_target_item_selected(index:int) -> void:
	match index:
		1:
			_attack.target = BattleAction.TargetType.ENEMIES
		2:
			_attack.target = BattleAction.TargetType.SELF
		3:
			_attack.target = BattleAction.TargetType.ALLY
		4:
			_attack.target = BattleAction.TargetType.ALLIES
		0,_:
			_attack.target = BattleAction.TargetType.ENEMY


func _on_range_item_selected(index:int) -> void:
	match index:
		0: 
			_attack.attack_range = BattleAction.AttackRange.MELEE
		1:
			_attack.attack_range = BattleAction.AttackRange.RANGED
		2,_:
			_attack.attack_range = BattleAction.AttackRange.STATUS

func _on_priority_value_changed(value:float) -> void:
	_attack.priority = int(value)

func _on_animation_item_selected(index:int) -> void:
	_attack.animation = animations[index]

func _on_element_item_selected(index:int) -> void:
	var element := ElementManager.elements[index]
	_attack.element = element

func _on_cost_value_changed(value:float) -> void:
	_attack.cost = int(value)

func _on_name_submitted(newText:String) -> void:
	_attack.name = newText

func _on_effect_builder_effect_created(effect:Effect) -> void:
	var effectButton = EffectSlotButton.instantiate()
	effectButton.create(effect)
	effects_scroller.add_child(effectButton)

	effectButton.delete_button_pressed.connect(func(): 
		effectButton.queue_free())

