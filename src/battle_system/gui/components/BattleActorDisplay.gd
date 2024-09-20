extends Control 
class_name BattleActorDisplay 

signal Selected(actor)
signal StatusEffectIconPressed(effect)

@export
var highlightDisplay: TextureRect 
@export
var nameLabel: Label 
@export
var healthBar: HSlider 
@export
var hpLabel: Label 
@export
var spriteDisplay: TextureRect 
@export
var statusEffectIcons: Control 
@export
var statChangeDisplay: StatChangeDisplay 
@export
var selectorButton: Button 

var Actor : BattleActor 

var tint : Color = Color.WHITE
var sprite: Sprite 
var totalHp: int 
# Dict<string, Node>
var icons = {}

func Setup(actor: BattleActor) -> void:
	nameLabel.text = actor.ActorName
	healthBar.value = (actor.CurrentHp / actor.Hp) * 100
	hpLabel.text = "%d/%d" % [actor.CurrentHp, actor.Hp ]
	totalHp = actor.Hp

	if actor.sprite == null:
		actor.UseGradientSprite()
	spriteDisplay.texture = actor.sprite.texture
	sprite = actor.sprite

	selectorButton.pressed.connect(func():
		Selected.emit(actor))

	Actor = actor
	actor.WasDefeated.connect(SetDefeated)
	actor.DamageApplied.connect(SetHealth)
	actor.StatusEffectAdded.connect(AddStatusEffect)
	actor.StatusEffectsRemoved.connect(RemoveStatusEffects)
	actor.ElementChanged.connect(SetElement)


func SetElement(id: int, element: ElementalType) -> void:
	# Update Sprite's colors.
	sprite.SetElement(id, element)
	# Update Sprite.
	spriteDisplay.texture = sprite.Texture

func SetHealth(hp: int) -> void:
	healthBar.value = hp / totalHp * 100.0
	hpLabel.text = "%d/%d" % [ hp, totalHp ]

func GetPosition() -> Vector2:
	var position = global_position
	position.x += size.x / 2
	position.y += size.y / 2

	return position

## Disallow selection
func DisableSelection() -> void:
	selectorButton.hide()
	tint = Color.WHITE
	SetHighlight(false)

func EnableSelection(color: Color) -> void:
	selectorButton.show()
	tint = color

func AddStatusEffect(effect: StatusEffect) -> void:
	if effect is StatChange:
		statChangeDisplay.Add(effect)
		return
	if(icons.contains_key(effect.Name)): return

	var icon = effect.InstantiateIcon()
	statusEffectIcons.add_child(icon)
	var button = icon.get_node("Button")
	button.pressed.connect(StatusEffectIconPressed)

	icons.append(effect.Name, icon)

func RemoveStatusEffects(effects) -> void:
	for effect in effects:
		if effect is StatChange:
			statChangeDisplay.remove(effect)
			continue
		
		if !icons.contains_key(effect.Name): continue
		var icon = icons[effect.Name]
		statusEffectIcons.remove_child(icon)
		icons.remove(effect.Name)

func SetDefeated() -> void:
	modulate = Color(1, 1, 1, .5)
	for key in icons.keys:
		var icon = icons[key]
		statusEffectIcons.remove_child(icon)
	icons.clear()

func SetHighlight(isHighlighted: bool) -> void:
	highlightDisplay.self_modulate =  Color(tint.r, tint.g, tint.b, 1 if isHighlighted  else  0)

func _on_mouse_entered() -> void:
	if(selectorButton.visible):
		SetHighlight(true)

func _on_mouse_exited() -> void:
	if(selectorButton.visible):
		SetHighlight(false)

func _OnStatusIconPressed(status: StatusEffect) -> void:
	pass
