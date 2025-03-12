extends Resource
class_name Dialog 

@export var id: String
@export var next := -1
@export var starting_emotion := "NEUTRAL"
## Name of animation that determines game's state after dialog is finished.
## E.g. if the player skips this dialog, is there an animation to skip thru.
@export var end_state: String
