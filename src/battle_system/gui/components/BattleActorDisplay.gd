extends Control 
class_name BattleActorDisplay 

signal selected(actor)
signal status_effect_icon_pressed(effect)

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

var actor : BattleActor 

var tint : Color = Color.WHITE
var sprite: Sprite 
var totalHp: int 
# Dict<string, Node>
var icons = {}

func setup(actor: BattleActor) -> void:
	nameLabel.text = actor.name
	healthBar.value = (actor.current_hp / actor.hp) * 100
	hpLabel.text = "%d/%d" % [actor.current_hp, actor.hp ]
	totalHp = actor.hp

	if actor.sprite == null:
		actor.use_gradient_sprite()
	spriteDisplay.texture = actor.sprite.texture
	sprite = actor.sprite

	selectorButton.pressed.connect(func():
		selected.emit(actor))

	self.actor = actor
	actor.was_just_defeated.connect(set_defeated)
	actor.damage_applied.connect(set_health)
	actor.status_effect_added.connect(add_status_effect)
	actor.status_effects_removed.connect(remove_status_effects)
	actor.element_changed.connect(set_element)


func set_element(id: int, element: ElementalType) -> void:
	# Update Sprite's colors.
	sprite.set_element(id, element)
	# Update Sprite.
	spriteDisplay.texture = sprite.texture

func set_health(hp: int) -> void:
	healthBar.value = hp / totalHp * 100.0
	hpLabel.text = "%d/%d" % [ hp, totalHp ]

func get_target_position() -> Vector2:
	var position = global_position
	position.x += size.x / 2
	position.y += size.y / 2
	return position

## Disallow selection
func disable_selection() -> void:
	selectorButton.hide()
	tint = Color.WHITE
	set_highlight(false)

func enable_selection(color: Color) -> void:
	selectorButton.show()
	tint = color

func add_status_effect(effect: StatusEffect) -> void:
	if effect is StatChange:
		statChangeDisplay.add(effect)
		return
	if(icons.has(effect.name)): return

	var icon = effect.instantiate_icon()
	statusEffectIcons.add_child(icon)
	var button = icon.get_node("Button")
	button.pressed.connect(func(): status_effect_icon_pressed.emit(effect))

	icons[effect.name] = icon

func remove_status_effects(effects) -> void:
	for effect in effects:
		if effect is StatChange:
			statChangeDisplay.remove(effect)
			continue
		
		if !icons.has(effect.name): continue
		var icon = icons[effect.name]
		statusEffectIcons.remove_child(icon)
		icons.remove(effect.name)

func set_defeated() -> void:
	modulate = Color(1, 1, 1, .5)
	for key in icons.keys():
		var icon = icons[key]
		statusEffectIcons.remove_child(icon)
	icons.clear()

func set_highlight(isHighlighted: bool) -> void:
	highlightDisplay.self_modulate =  Color(tint.r, tint.g, tint.b, 1 if isHighlighted  else  0)

func _on_mouse_entered() -> void:
	if(selectorButton.visible):
		set_highlight(true)

func _on_mouse_exited() -> void:
	if(selectorButton.visible):
		set_highlight(false)

func _on_status_icon_pressed(status: StatusEffect) -> void:
	pass
