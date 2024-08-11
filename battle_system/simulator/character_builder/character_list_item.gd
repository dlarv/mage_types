extends Control

@export var name_display: Label
@export var element1_display: ColorRect
@export var element2_display: ColorRect
@export var team1_button: CheckBox
@export var team2_button: CheckBox
@export var delete_button: Button
@export var selector: CheckBox

var character: BattleActor.Fighter
var _team_index: int

func _ready():
	team1_button.pressed.connect(_on_team_index_set.bind(0))
	team2_button.pressed.connect(_on_team_index_set.bind(1))

func create(character: BattleActor.Fighter):
	self.character = character
	name_display.text = character.actor_name
	element1_display.color = character.primary_element.color
	
	if character.secondary_element != null:
		element2_display.color = character.secondary_element.color

	return delete_button

func get_team_index() -> int:
	return _team_index

func set_team_index(index: int):
	_team_index = index
	if index == 0:
		team1_button.set_pressed(true)
	else:
		team2_button.set_pressed(true)

func _on_team_index_set(index: int):
	_team_index = index
