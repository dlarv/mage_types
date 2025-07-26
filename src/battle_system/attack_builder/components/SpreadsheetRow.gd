@tool
extends Resource

@warning_ignore_start("untyped_declaration")
signal selected(row)

var select: CheckBox
var name: LineEdit
var elements: OptionButton
var attackRange: OptionButton
var targets: OptionButton
var priority: SpinBox
var power: SpinBox
var accuracy: SpinBox
var description: TextEdit
var attack: Attack

func _init(select=null, name=null, elements=null, attackRange=null, targets=null, priority=null, power=null, accuracy=null, description=null, attack=null):
	self.select = select
	self.name = name
	self.name.text_submitted.connect(func(text: String): self.attack.name = text)
	self.elements = elements
	self.elements.item_selected.connect(func(index: int): 
		if index == 0:
			self.attack.element = ElementManager.Blank
		else:
			var element := ElementManager.elements[index - 1]
			self.attack.element = element)
	self.attackRange = attackRange
	self.attackRange.item_selected.connect(func(index: int):
		self.attack.attack_range = index as _BattleAction.AttackRange)
	self.targets = targets
	self.targets.item_selected.connect(func(index: int):
		self.attack.target = index as _BattleAction.TargetType)
	self.priority = priority
	self.priority.value_changed.connect(func(val: float): self.attack.priority = int(val))
	self.power = power
	self.power.value_changed.connect(func(val: float): self.attack.power = int(val))
	self.accuracy = accuracy
	self.accuracy.value_changed.connect(func(val: float): self.attack.accuracy = val)
	self.description = description
	self.description.text_changed.connect(func(): self.attack.details = self.description.text)
	if attack:
		self.attack = attack
	else:
		self.attack = Attack.new()

	select.pressed.connect(func(): selected.emit(self))


func delete() -> void:
	select.queue_free()
	name.queue_free()
	elements.queue_free()
	attackRange.queue_free()
	targets.queue_free()
	priority.queue_free()
	power.queue_free()
	accuracy.queue_free()
	description.queue_free()


func update() -> void:
	if attack:
		name.text = attack.name
		if not attack.element.is_blank():
			elements.selected = ElementManager.elements.find(attack.element) + 1
		else:
			elements.selected = 0
		attackRange.selected = attack.attack_range
		targets.selected = attack.target
		priority.value = attack.priority
		power.value = attack.power
		accuracy.value = attack.accuracy
		description.text = attack.details
