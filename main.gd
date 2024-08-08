extends Node

@export var builder: Control
@export var simulator: Node2D

func _ready():
	builder.setup_finished.connect(_on_setup_finished)
	builder.show()
	simulator.hide()

func _on_setup_finished(team1: Array, team2: Array):
	simulator.start(team1, team2)
	builder.hide()
	simulator.show()
