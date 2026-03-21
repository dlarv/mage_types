extends Window

const ACTION_USE_LEADER    := "[color=#ff0000][lb]ACTION[rb][/color]"
const ACTION_TARGET_LEADER := "[color=#800000][lb]TARGET[rb][/color]"
const ACTION_EFFECT_LEADER := "[color=#ff8000][lb]EFFECT[rb][/color]"
const DEFEAT_LEADER 	   := "[color=#ffffff][lb]DEFEAT[rb][/color]"
const STATUS_EFFECT_LEADER := "[color=#0000ff][lb]STATUS[rb][/color]"
const EXPIRE_EFFECT_LEADER := "[color=#000080][lb]EXPIRE[rb][/color]"
const TRANSMUTATION_LEADER := "[color=#00ff00][lb]TRNSMT[rb][/color]"
const SIDE_EFFECT_LEADER   := "[color=#008000][lb]SIDEFX[rb][/color]"
const INFO_LEADER 		   := "[color=#808080][lb]*INFO*[rb][/color]"
const EQUIPMENT_LEADER     := "[color=#ffff00][lb]EQUIPM[rb][/color]"


func setup(actors: Array[BattleActor]) -> void:
	for actor in actors:
		if not actor.status_activated.is_connected(append_activated_status_effect_message):
			actor.status_activated.connect(append_activated_status_effect_message.bind(actor))
		if not actor.equipment_activated.is_connected(append_equipment_effect_message):
			actor.equipment_activated.connect(append_equipment_effect_message.bind(actor))


func append_turn_header(turn: int) -> void:
	_append_text("[center][b]Turn %d[/b][/center]" % turn, false)


func append_action_message(data: ActorTurnData) -> void:
	_append_user_messages(data)

	for actor in data.effects:
		_append_target_messages(actor, data.effects[actor])


func _append_user_messages(data: ActorTurnData) -> void:
	_append_text("%s %s used %s!" % [ACTION_USE_LEADER, data.user.name, data.action.name])

	if data.recoil_dmg > 0:
		_append_text("%s This attack had recoil (%d dmg)" 
				% [ACTION_EFFECT_LEADER, data.recoil_dmg])
	
	for status in data.new_status_effects:
		_append_text("%s %s" % [
			ACTION_EFFECT_LEADER, 
			status.message.replace("{element}", str(status.get("element"))).replace("{target}", data.user.name)
		])
	
	if data.user_was_defeated:
		_append_text("%s %s was defeated..." % [DEFEAT_LEADER, data.user.name])


func _append_target_messages(target: BattleActor, effect: ActorTurnData.ActorTurnEffect) -> void:
	if effect.missed:
		_append_text("%s The attack missed %s!" % [ACTION_TARGET_LEADER, target.name])
		return
	elif effect.blocked_dmg > 0 and effect.dmg > 0:
		_append_text("%s %s deflected some of the damage! (Took %d dmg, blocked %d dmg)" 
				% [ACTION_TARGET_LEADER, target.name, effect.dmg, effect.blocked_dmg])
	elif effect.dmg > 0:
		_append_text("%s The attack connected with %s! (%d dmg)" 
				% [ACTION_TARGET_LEADER, target.name, effect.dmg])
	elif effect.blocked_dmg > 0:
		_append_text("%s %s blocked the attack! (%d dmg)" 
				% [ACTION_TARGET_LEADER, target.name, effect.blocked_dmg])
	else:
		_append_text("%s The attack connected with %s!" % [ACTION_TARGET_LEADER, target.name])
	
	for status in effect.new_status_effects:
		_append_text("%s %s" % [
			ACTION_EFFECT_LEADER, 
			status.message.replace("{element}", str(status.get("element"))).replace("{target}", target.name)
		])
	
	if effect.was_defeated:
		_append_text("%s %s was defeated!" % [DEFEAT_LEADER, target.name])


func append_transmutation_message(actor: BattleActor, start: ElementalType, end: ElementalType, att: ElementalType, isInternal: bool) -> void:
	if isInternal:
		var primary := att
		_append_text("%s %s's primary [el]%s[/el] + secondary [el]%s[/el] => [el]%s[/el]" 
				% [TRANSMUTATION_LEADER, actor.name, start.name, primary.name, end.name])
	else:
		_append_text("%s %s's [el]%s[/el] + Attack's [el]%s[/el] => [el]%s[/el]" 
				% [TRANSMUTATION_LEADER, actor.name, start.name, att.name, end.name])


func append_side_effect_message(actor: BattleActor, buff: StatChange) -> void:
	_append_text("%s This transmutation had side effects!" % [SIDE_EFFECT_LEADER])


func append_expired_status_effects_message(data: ActorTurnData) -> void:
	for effect in data.expired_status_effects:
		_append_text("%s %s' %s wore off" % [EXPIRE_EFFECT_LEADER, data.user.name, effect.name])


func append_info(msg: String) -> void:
	_append_text("%s %s" % [INFO_LEADER, msg])


func append_activated_status_effect_message(effect: StatusEffect, data: Variant, target: BattleActor) -> void:
	var msg := ""
	match effect.id:
		StatusEffect.Effects.POISON:
			msg = "%s %s was hurt by poison! (%d dmg)" % [STATUS_EFFECT_LEADER, target.name, int(data)]
		StatusEffect.Effects.STASIS:
			if data:
				append_info("Melee attack's also cause transmutations in their user!")
			msg = "%s %s is in stasis! Transmutations were blocked!" % [STATUS_EFFECT_LEADER, target.name]
		StatusEffect.Effects.HEALING:
			msg = "%s %s healed %d hp!" % [STATUS_EFFECT_LEADER, target.name, int(data)]
		StatusEffect.Effects.PHOBIC:
			msg = "%s %s was hurt by their phobia! (%d dmg)" % [STATUS_EFFECT_LEADER, target.name, int(data)]
		StatusEffect.Effects.FLINCH:
			msg = "%s %s flinched! They were unable to move." % [STATUS_EFFECT_LEADER, target.name]


	_append_text(msg)


func append_equipment_effect_message(equip: Equipment, actor: BattleActor) -> void:
	_append_text("%s %s's %s activated!" % [EQUIPMENT_LEADER, actor.name, equip.name])


func _append_text(msg: String, writeLog:=true) -> void:
	var label := RichTextLabel.new()
	label.fit_content = true
	label.bbcode_enabled = true
	label.custom_effects.append(RichTextElement.new())
	%Scroller.add_child(label)

	label.append_text(msg)
	label.newline()

	if writeLog:
		MyLogger.append_battle_log(msg)


# Used by Battle.gd to create a space between different actors, but not between first actor and turn heading
func newline() -> void: _append_text(" ")
