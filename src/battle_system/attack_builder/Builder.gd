@tool
extends PanelContainer

signal back_button_pressed()

const Row := preload("components/SpreadsheetRow.gd")
const EffectSlotButton := preload("components/effect_slot.tscn")

@export var path := "res://data/battle_system/battle_actions/attacks"
@export var animations_path := "res://src/battle_system/battle_actions/animations/"
@export var effects_scroller: VBoxContainer
@export var _animation_option_button: OptionButton
@export var _details_text_box: TextEdit

var animations: Array[PackedScene]
var _attack: Attack = Attack.new()
var _row: Row = null
var _output_path := ""

func _enter_tree():
	_animation_option_button.clear()
	animations = []

	var animationsDir := DirAccess.open(animations_path)
	animationsDir.list_dir_begin()
	var fileName := animationsDir.get_next()
	while fileName != "":
		if fileName.ends_with(".tscn"):
			_animation_option_button.add_item(fileName.split("/")[-1].split(".")[0])
			animations.append(load(animations_path + "/" + fileName))
		fileName = animationsDir.get_next()

	
	default_attack()


func _exit_tree():
	_animation_option_button.clear()


func default_attack() -> void:
	_attack = Attack.new()
	_attack.animation = animations[0]


func _on_details_text_changed() -> void:
	_attack.details = _details_text_box.text


func _on_target_item_selected(index:int) -> void:
	match index:
		1:
			_attack.target = _BattleAction.TargetType.ENEMIES
		2:
			_attack.target = _BattleAction.TargetType.SELF
		3:
			_attack.target = _BattleAction.TargetType.ALLY
		4:
			_attack.target = _BattleAction.TargetType.ALLIES
		0,_:
			_attack.target = _BattleAction.TargetType.ENEMY


func _on_range_item_selected(index:int) -> void:
	match index:
		0: 
			_attack.attack_range = _BattleAction.AttackRange.MELEE
		1:
			_attack.attack_range = _BattleAction.AttackRange.RANGED
		2,_:
			_attack.attack_range = _BattleAction.AttackRange.STATUS


func _on_priority_value_changed(value:float) -> void:
	_attack.priority = int(value)


func _on_animation_item_selected(index:int) -> void:
	_attack.animation = animations[index]


func _on_element_item_selected(index:int) -> void:
	if index == 0:
		_attack.element = ElementManager.Blank
	else:
		var element := ElementManager.elements[index - 1]
		_attack.element = element
	_attack._element = _attack.element.name.to_lower()


func _on_name_submitted(newText:String) -> void:
	_attack.name = newText


func _on_effect_builder_effect_created(effect:EffectSlot) -> void:
	var effectButton = EffectSlotButton.instantiate()
	effectButton.create(effect)
	effects_scroller.add_child(effectButton)

	effectButton.delete_button_pressed.connect(func(): 
		effectButton.queue_free())


func _on_accuracy_value_changed(value:float) -> void:
	_attack.accuracy = value


func _on_save_button_pressed() -> void:
	_copy_attack(_row.attack, _attack)
	_row.update()

	_attack.effects = []
	for effect in effects_scroller.get_children():
		_attack.effects.append(effect.get_effect())

	if true or Engine.is_editor_hint():
		# Save attack to fs.
		var p: String
		if _output_path.is_empty():
			print("Generating path")
			p = "%s/%s.tres" % [ path, _attack.name.to_lower().replace(" ", "_") ]
		else:
			p = _output_path

		print("Saving attack to %s." % p)
		
		var err := ResourceSaver.save(_attack, p)
		if err != OK:
			print("Error: " + error_string(err))
	else:
		# Create SpellScroll and give it to player.
		print("Creating spell scroll...")
		var err := ResourceSaver.save(_attack, "%s/%s.tres" % [ path, _attack.name ])
		if err != OK:
			print("Error: " + error_string(err))


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	_row = null


func open_row(row: Row) -> void:
	_row = row
	# _attack = row.attack
	_attack = row.attack.duplicate(true)
	_output_path = row.attack.resource_path


	var attack: Attack = row.attack
	if attack:
		%NameLineEdit.text = attack.name
		if not attack.element.is_blank():
			var index :=ElementManager.elements.find(attack.element) + 1
			%ElementOptionButton.selected = index
		else:
			%ElementOptionButton.selected = 0
		%RangeOptionButton.selected = attack.attack_range
		%TargetOptionButton.selected = attack.target
		%PrioritySpinBox.value = attack.priority

		for i in (%AnimationOptionButton as OptionButton).item_count:
			if attack.animation and %AnimationOptionButton.get_item_text(i).to_lower() == attack.animation.resource_path.split("/")[-1].split(".")[0].to_lower():
				%AnimationOptionButton.selected = i
				break

		%PowerSpinBox.value = attack.power
		%AccuracySpinBox.value = attack.accuracy
		%DetailsTextEdit.text = attack.details


func _on_power_value_changed(value:float) -> void:
	_attack.power = int(value) 


func _copy_attack(a: Attack, b: Attack) -> void:
	a.name = b.name
	a.target = b.target
	a.attack_range = b.attack_range
	a.element = b.element
	a._element = b._element
	a.priority = b.priority
	a.accuracy = b.accuracy
	a.power = b.power
	a.animation = b.animation
	a.details = b.details
	
