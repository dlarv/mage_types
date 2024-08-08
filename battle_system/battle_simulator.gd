extends Node2D
class_name BattleSimulator

signal message_created(msg: String)

var Fighter = BattleActor.Fighter

@export var player_control: PlayerControl
@export var player_sprite: TextureRect
@export var player_health_bar: Control

@export var opponent_gui_layer: CanvasLayer
@export var opponent_control: OpponentControl
@export var opponent_sprite: TextureRect
@export var opponent_health_bar: Control

var players = []
var active_player: BattleActor.Fighter
var opponents = []
var active_opponent: BattleActor.Fighter


func _ready():
	player_control.hide()
	opponent_gui_layer.hide()


func start(team1: Array, team2: Array):
	player_control.show()
	opponent_gui_layer.show()
	
	players = team1
	set_actor(team1[0], 0)
	player_control.populate_team_controls(team1)
	
	opponents = team2
	set_actor(team2[0], 1)


func set_actor(actor: BattleActor.Fighter, index: int):
	if index == 0:
		player_control.populate_attack_controls(actor)
		player_sprite.texture = actor.sprite.texture
		player_health_bar.set_display(actor)
		active_player = actor
	else:
		opponent_sprite.texture = actor.sprite.texture
		opponent_health_bar.set_display(actor)
		active_opponent = actor


func _on_team_switching_actor(actor: BattleActor.Fighter, team_index: int):
	set_actor(actor, team_index)
	player_control.switch(0)


func _on_team_using_attack(attack: Attack, team_index: int):
	player_control.switch(0)
	var animation = attack.get_tinted_animation()
	var target
	var target_sprite
	var user_sprite
	var user
	var target_name
	var user_name
	if team_index == 0:
		target_name = "Opponent %s" % active_opponent.actor_name
		user_name = "Player %s" % active_player.actor_name
		target = active_opponent
		user = active_player
		target_sprite = opponent_sprite
		user_sprite = player_sprite
	else:
		target_name = "Player %s" % active_player.actor_name
		user_name = "Opponent %s" % active_opponent.actor_name
		target = active_player
		user = active_opponent
		target_sprite = player_sprite
		user_sprite = opponent_sprite
	
	animation.superimpose(user_sprite, target_sprite, team_index == 1)

	
	# Calculate damage
	var damage = calculate_damage(user, target, attack)
	await player_control.show_message("%s used %s on %s (%d damage)" % [
		user_name.to_upper(),
		attack.attack_name.to_upper(),
		target_name.to_upper(),
		damage
	])
	
	# Calculate target transmutations
	await perform_transmutations(target, attack, target_name, target_sprite)
	
	# If melee attack, calculate user's transmutations
	# TODO
	
	# Advance turn
	if team_index == 0:
		player_control.set_enabled(false)
		opponent_control._calculate_move( \
			active_opponent, 
			opponents,
			active_player)
	else:
		player_control.set_enabled(true)


func calculate_damage(attacker: BattleActor.Fighter, defender: BattleActor.Fighter, attack: Attack):
	var stat_comp = attacker.attack / defender.defense
	var rand = randf_range(0.8, 1.0)
	var power = attack.power
	var stab_exp = MatchupManager.get_matchup(attacker.primary_element, attack.element).modifier \
		+ MatchupManager.get_matchup(attacker.secondary_element, attack.element).modifier
	var stab = pow(2, stab_exp)

	var matchup_exp = MatchupManager.get_matchup(defender.primary_element, attack.element).modifier \
		+ MatchupManager.get_matchup(defender.secondary_element, attack.element).modifier
	var matchup = pow(2, matchup_exp)
	
	return stat_comp * rand * power * stab * matchup


func perform_transmutations(target: BattleActor.Fighter, attack: Attack, name: String, sprite: TextureRect):
	var mutations = calculate_transmutations(target, attack)
	if not mutations[0].is_empty():

		await player_control.show_message( \
			"Opponent's %s type reacted with the attack's %s type to form %s!" % [
				target.primary_element.type_name.to_upper(),
				attack.element.type_name.to_upper(),
				mutations[0].element.type_name.to_upper()
			])
	if not mutations[1].is_empty():
		await player_control.show_message( \
			"%s's %s type reacted with the attack's %s type to form %s!" % [
				name,
				target.secondary_element.type_name.to_upper(),
				attack.element.type_name.to_upper(),
				mutations[1].element.type_name.to_upper()
			])
	target.transmute(mutations[0], mutations[1])
	sprite.texture = target.sprite.texture
	
	# Calc if target's new types react with themselves
	var self_reaction = MatchupManager.get_matchup(target.primary_element, target.secondary_element)
	if not self_reaction.is_empty():
		target.transmute(self_reaction)
		await player_control.show_message("%s's primary and secondary types reacted to form %s!" %[
			target.actor_name.to_upper(),
			self_reaction.element.type_name.to_upper()
		])

func calculate_transmutations(actor: BattleActor.Fighter, attack: Attack):
	var m1 = MatchupManager.get_matchup(actor.primary_element, attack.element)
	var m2 = MatchupManager.get_matchup(actor.secondary_element, attack.element)
	return [m1, m2]
