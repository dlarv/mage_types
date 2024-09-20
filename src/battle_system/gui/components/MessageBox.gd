extends RichTextLabel 
class_name MessageBox 

signal MessageCleared()

@export
var button: Button 

func _Ready() -> void:
	button.pressed.connect(ClearMessage)

func DisplayMessageBlocking(msg: String) -> void:
	ClearMessage()
	text = msg
	await button.pressed

func DisplayMessageNonBlocking(msg: String, obj=null) -> void:
	ClearMessage()
	if obj == null:
		text = msg

	elif obj is Attack:
		FormatAttack(obj)

	elif obj is BattleItem:
		FormatItem(obj)

	elif obj is StatusEffect:
		FormatStatusEffect(obj)

	elif obj is BattleActor:
		FormatBattleActor(obj)


func FormatAttack(attack: Attack) -> void:
	AppendTitle(attack.Name)
	AppendElementalType(attack.Element)

	AppendHeader("Range")
	append_text(str(attack.ARange))
	newline()

	AppendHeader("Cost")
	append_text(str(attack.Cost))
	newline()

	if len(attack.Details) > 0:
		AppendHeader("Description")
		newline()
		append_text(attack.Details)


func FormatItem(item: BattleItem) -> void:
	AppendTitle(item.Name)

	if item.Element != ElementManager.Blank:
		AppendElementalType(item.Element)

	if item.IsConsumable:
		AppendHeader("Quantity")
		append_text(str(item.Quantity))
		newline()

	
	if len(item.Details) > 0:
		AppendHeader("Description")
		newline()
		append_text(item.Details)


func FormatStatusEffect(effect: StatusEffect) -> void:
	AppendTitle(effect.Name)
	AppendHeader("Strength")
	append_text(str(effect.Strength * 100.0) + "%")
	newline()
	AppendHeader("Duration")
	append_text(str(effect.Duration))
	newline()

func FormatBattleActor(actor: BattleActor) -> void:
	AppendTitle(actor.ActorName)
	AppendElementalType(actor.Element1, "Primary Element")
	AppendElementalType(actor.Element2, "Secondary Element")

	newline()
	AppendHeader("Status Effects")
	newline()
	for effect in actor.ListStatusEffects():
		FormatStatusEffect(effect)


	newline()
	AppendHeader("Stats")
	newline()
	AppendHeader("Hp")
	append_text("%d/%d" % [ actor.CurrentHp, actor.Hp ])
	newline()

	AppendHeader("Mana")
	append_text(str(actor.Mana))
	newline()

	AppendHeader("Melee Attack")
	append_text(str(actor.MeleeAttack))
	newline()

	AppendHeader("Ranged Attack")
	append_text(str(actor.RangedAttack))
	newline()

	AppendHeader("Melee Defense")
	append_text(str(actor.MeleeAttack))
	newline()

	AppendHeader("Ranged Defense")
	append_text(str(actor.RangedDefense))
	newline()

	AppendHeader("Speed")
	append_text(str(actor.Speed))
	newline()

	newline()
	AppendHeader("Attacks")
	newline()
	for attack in actor.Attacks:
		FormatAttack(attack)

# [underline]<title>[/underline]\n
func AppendTitle(title: String) -> void:
	push_underline()
	append_text(title)
	pop()
	newline()

# [bold]<val>[/bold]: 
func AppendHeader(val: String) -> void:
	push_bold()
	append_text(val)
	pop() # End bold 
	append_text(": ")
# [color]<element.Name>[/color]\n
func AppendElementalType(element: ElementalType, msg: String="Element") -> void:
	AppendHeader(msg)
	push_color(element.MainColor)
	append_text(element.Name)
	pop() # End color
	newline()

func ClearMessage()-> void:
	text = ""
	clear()
