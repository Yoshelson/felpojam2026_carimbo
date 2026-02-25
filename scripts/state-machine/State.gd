extends Node
class_name State

@export var id: String
var player: Player
signal change_state(state: String)

func enter_state():
	pass

func exit_state():
	pass
	
func inputs(event: InputEvent):
	pass
	
func update(delta: float):
	pass
	
func physics_update(delta: float):
	pass
