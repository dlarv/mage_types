extends Control

const BubbleContainer := preload("components/bubble_container.tscn")
const AffinityBubble := preload("components/affinity_bubble.tscn")
const ActionBubble := preload("components/action_bubble.tscn")
const ActorHeaderBubble := preload("components/actor_header_bubble.tscn")
const TurnHeaderBubble := preload("components/turn_header_bubble.tscn")
const TransmutationBubble := preload("components/transmutation_bubble.tscn")
const DefeatBubble := preload("components/defeat_bubble.tscn")
const NewStatusEffectBubble := preload("components/new_status_effect_bubble.tscn")
const OldStatusEffectBubble := preload("components/old_status_effect_bubble.tscn")

var bubble_container: Control
var scroll_container: ScrollContainer
var scroll_bar: VScrollBar


func _ready() -> void:
	scroll_container = %Scroller.get_parent()
	scroll_bar = scroll_container.get_v_scroll_bar()


func append_turn_header(turn: int) -> void:
	var turnHeader := TurnHeaderBubble.instantiate()
	turnHeader.setup(turn)
	%Scroller.add_child(turnHeader)
	bubble_container = null

	scroll_container.set_deferred("scroll_vertical", scroll_bar.max_value)


func append_actor_header(actor: BattleActor) -> void:
	bubble_container = BubbleContainer.instantiate()
	%Scroller.add_child(bubble_container)

	var header := ActorHeaderBubble.instantiate()
	header.setup("%s's Turn" % actor.name)
	bubble_container.add_bubble(header)

	scroll_container.set_deferred("scroll_vertical", scroll_bar.max_value)


func append_action_message(data: ActorTurnData) -> void:
	var actionBubble := ActionBubble.instantiate()
	actionBubble.setup(data)
	bubble_container.add_bubble(actionBubble)

	var affinityBubble := AffinityBubble.instantiate()
	affinityBubble.setup(data)
	bubble_container.add_bubble(affinityBubble)

	for actorEffectPair: Array in data.new_status_effects:
		var statusBubble := NewStatusEffectBubble.instantiate()
		statusBubble.setup(actorEffectPair)
		bubble_container.add_bubble(statusBubble)

	for actorEffectPair: Array in data.removed_status_effects:
		var statusBubble := OldStatusEffectBubble.instantiate()
		statusBubble.setup(actorEffectPair)
		bubble_container.add_bubble(statusBubble)

	scroll_container.set_deferred("scroll_vertical", scroll_bar.max_value)


func append_defeated_message(data: ActorTurnData) -> void:
	for actor in data.defeated_actors:
		var defeatBubble := DefeatBubble.instantiate()
		defeatBubble.setup(actor.name)
		bubble_container.add_bubble(defeatBubble)


func append_transmutation_message(actor: BattleActor, e1: ElementalType, e2: ElementalType, att: ElementalType) -> void:
	var transBubble := TransmutationBubble.instantiate()
	transBubble.setup([actor, e1, att, e2])
	bubble_container.add_bubble(transBubble)

	scroll_container.set_deferred("scroll_vertical", scroll_bar.max_value)


func append_removed_status_effect_message(actor: BattleActor, effect: StatusEffect) -> void:
		var statusBubble := OldStatusEffectBubble.instantiate()
		statusBubble.setup([actor, effect])
		bubble_container.add_bubble(statusBubble)


func _get_panel(text: String) -> Control:
	var container := MarginContainer.new()
	var label := Label.new()
	label.text = text
	container.add_child(label)
	return container


