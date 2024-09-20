extends Node
class_name BattleGUI

signal ActionsSelected(actions)
signal BattleEnded()

@export
var messageBox: MessageBox 
@export
var AllyDisplayParent : TeamDisplay 
@export
var EnemyDisplayParent : TeamDisplay 
@export
var playerControls: PlayerControls 

# BattleActor[]
var allies = []
var enemies = []
# String[]
var messages = []
# ActorAction[]
var selectedActions = []

func Setup(allies, items, enemies) -> void:
	InitAllies(allies)
	InitEnemies(enemies)
	# AddItemsToInventory(items)
	playerControls.Setup(allies, items, enemies)


func InitAllies(allies) -> void:
	self.allies = allies
	selectedActions = []
	selectedActions.resize(len(allies))

	for actor in allies:
		AllyDisplayParent.AddDisplay(actor)
	
	AllyDisplayParent.Highlight(0)


func InitEnemies(enemies) -> void:
	self.enemies = enemies
	for actor in enemies:
		EnemyDisplayParent.AddDisplay(actor)
	


# private void AddItemsToInventory(BattleItem[] items) {
# 
#
# public void PlayAnimation(PackedScene animation, Vector2 start, Vector2 end) {


func DisplayMessage(msg: String) -> void:
	messages.append(msg)
	await messageBox.DisplayMessageBlocking(msg)

func DisplayMessageNonBlocking(msg: String, obj=null) -> void:
	messages.append(msg)
	messageBox.DisplayMessageNonBlocking(msg, obj)


# public void AddStatusEffect(StatusEffect effect, BattleActor target) {
# public void RemoveStatusEffect(StatusEffect effect, BattleActor target) {
# public void ChangeHealth(int newHealth, BattleActor target) {
# public void RemoveActor(BattleActor target) {

func GetActorDisplayPosition(teamIndex: int, actor=null) -> Vector2:
	var teamDisplay
	if teamIndex == 0:
		teamDisplay = AllyDisplayParent
	else:
		teamDisplay = EnemyDisplayParent
	

	if actor == null:
		return teamDisplay.global_position
	

	var display = teamDisplay.GetDisplay(actor)
	return display.get_position()

func EnablePlayerControls(enable: bool) -> void:
	playerControls.SetEnabled(enable)


func _on_action_selected(index: int, action: BattleAction) -> void:
	var targets = await SelectTargets(allies[index], action)

	var actorAction = ActorAction.new(allies[index], action, targets, 0)
	selectedActions[index] = actorAction
	messageBox.ClearMessage()
	playerControls.NextCharacter()

func SelectTargets(user: BattleActor, action:BattleAction):
	var targets = null
	var target

	match action.Target:
		BattleAction.TargetType.Self:
			targets = [ user ]
			# This pause is needed, otherwise the End turn button won't enable.
			await get_tree().create_timer(.05).timeout
			
		BattleAction.TargetType.Ally:
			if AllyDisplayParent.Length == 1:
				targets = [ AllyDisplayParent.GetDisplay(0).Actor ]
				# This pause is needed, otherwise the End turn button won't enable.
				await get_tree().create_timer(.05).timeout
			else:
				AllyDisplayParent.SelectTarget(false)
				target = await AllyDisplayParent.Selected
				targets = [ target ]
			
		BattleAction.TargetType.Allies:
			targets = allies
			
		BattleAction.TargetType.Enemy:
			if EnemyDisplayParent.Length == 1:
				targets = [ EnemyDisplayParent.GetDisplay(0).Actor ]
				# This pause is needed, otherwise the End turn button won't enable.
				await get_tree().create_timer(.05).timeout
			else:
				EnemyDisplayParent.SelectTarget(true)
				target = await EnemyDisplayParent.Selected
				targets = [ target ]
		BattleAction.TargetType.Enemies:
			targets = enemies
			
	return targets

func _on_active_actor_changed(index: int) -> void:
	AllyDisplayParent.Highlight(index)

func _on_turn_ended(tryRunningAway: bool) -> void:
	if tryRunningAway:
		ActionsSelected.emit(null)
	else:
		ActionsSelected.emit(selectedActions)
		selectedActions = []
		selectedActions.resize(len(allies))
	

func _on_show_info(action) -> void:
	var msg = "Empty"
	if action is BattleAction:
		msg = action.Name
	elif (action is BattleActor):
		msg = action.ActorName
	print(msg)
	
	DisplayMessageNonBlocking("", action)


